terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  # Partial backend config: resource_group_name, storage_account_name and
  # container_name are supplied at `terraform init` time via -backend-config
  # (see .github/workflows/terraform-production.yml, or backend-config.hcl for local use).
  backend "azurerm" {
    key = "production.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  use_oidc        = true
}

# ---------------------------------------------------------
# Resource Group
# ---------------------------------------------------------
module "rg_prod" {
  source   = "../../modules/resource-group"
  name     = "rg-vnet-prod-uaenorth-01"
  location = var.location
  tags     = var.tags
}

# ---------------------------------------------------------
# Virtual Network
# ---------------------------------------------------------
module "vnet_prod" {
  source               = "../../modules/vnet"
  name                 = "vnet-viwell-prod-uaenorth-01"
  resource_group_name  = module.rg_prod.name
  location             = var.location
  address_space        = ["10.30.0.0/16"]

  subnets = {
    "snet-apps-prod-uaenorth-01" = {
      address_prefixes = ["10.30.0.64/26"]
    }
    "snet-prvtendpt-prod-uaenorth-01" = {
      address_prefixes = ["10.30.0.128/26"]
    }
    # NOTE: source table listed this as 10.20.0.192/27, which falls inside
    # the staging (10.20.0.0/16) address space, not prod (10.30.0.0/16).
    # Using 10.30.0.192/27 here — confirm with your network team and
    # correct if the table's value was intentional.
    "snet-db-prod-uaenorth-01" = {
      address_prefixes   = ["10.30.0.192/27"]
      delegation_name     = "postgres-delegation"
      delegation_service  = "Microsoft.DBforPostgreSQL/flexibleServers"
    }
  }

  tags = var.tags
}

# ---------------------------------------------------------
# ACR
# ---------------------------------------------------------
module "acr_prod" {
  source                   = "../../modules/acr"
  name                     = "acrviwellproduaenorth01"
  resource_group_name      = module.rg_prod.name
  location                 = var.location
  sku                      = "Premium"
  zone_redundancy_enabled  = true
  tags                     = var.tags
}

# ---------------------------------------------------------
# AKS
# ---------------------------------------------------------
module "aks_prod" {
  source                = "../../modules/aks"
  name                  = "aks-viwell-prod-uaenorth-01"
  resource_group_name   = module.rg_prod.name
  location              = var.location
  dns_prefix            = "aksviwellprod"
  vnet_subnet_id         = module.vnet_prod.subnet_ids["snet-apps-prod-uaenorth-01"]
  acr_id                = module.acr_prod.id
  node_count            = 3
  vm_size               = "Standard_D4s_v3"
  availability_zones    = ["1", "2", "3"]
  tags                  = var.tags
}

# ---------------------------------------------------------
# PostgreSQL Flexible Server
# ---------------------------------------------------------
module "postgresql_prod" {
  source                        = "../../modules/postgresql"
  name                          = "psql-viwell-prod-uaenorth-01"
  resource_group_name          = module.rg_prod.name
  location                      = var.location
  administrator_login           = var.postgres_administrator_login
  administrator_password        = var.postgres_administrator_password
  delegated_subnet_id           = module.vnet_prod.subnet_ids["snet-db-prod-uaenorth-01"]
  private_dns_zone_id           = var.postgres_private_dns_zone_id
  sku_name                      = "GP_Standard_D2s_v3"
  geo_redundant_backup_enabled  = true
  backup_retention_days         = 14
  zone                          = "1"
  high_availability_enabled     = true
  standby_availability_zone     = "2"
  tags                          = var.tags
}

# ---------------------------------------------------------
# Function App
# ---------------------------------------------------------
module "function_app_prod" {
  source                 = "../../modules/function-app"
  name                   = "func-viwell-prod-uaenorth-01"
  resource_group_name   = module.rg_prod.name
  location                = var.location
  storage_account_name   = "stviwellproduaenorth01"
  storage_account_replication_type = "ZRS"
  service_plan_sku       = "EP1"
  zone_balancing_enabled = true
  service_plan_worker_count = 3
  vnet_subnet_id          = module.vnet_prod.subnet_ids["snet-apps-prod-uaenorth-01"]
  tags                    = var.tags
}

# ---------------------------------------------------------
# Redis Cache
# ---------------------------------------------------------
module "redis_prod" {
  source                       = "../../modules/redis"
  name                         = "redis-viwell-prod-uaenorth-01"
  resource_group_name         = module.rg_prod.name
  location                     = var.location
  capacity                    = 1
  family                       = "P"
  sku_name                    = "Premium"
  zones                        = ["1", "2", "3"]
  enable_private_endpoint     = true
  private_endpoint_subnet_id  = module.vnet_prod.subnet_ids["snet-prvtendpt-prod-uaenorth-01"]
  private_dns_zone_ids        = var.redis_private_dns_zone_ids
  tags                         = var.tags
}

# ---------------------------------------------------------
# Event Hub
# Zone redundancy is automatic for Standard/Premium namespaces in
# zone-enabled regions (UAE North qualifies) — no explicit config needed.
# ---------------------------------------------------------
module "eventhub_prod" {
  source               = "../../modules/eventhub"
  namespace_name       = "evhns-viwell-prod-uaenorth-01"
  eventhub_name        = "evh-viwell-prod-uaenorth-01"
  resource_group_name  = module.rg_prod.name
  location             = var.location
  sku                  = "Standard"
  capacity             = 2
  tags                 = var.tags
}
