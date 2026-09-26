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
  # (see .github/workflows/terraform-staging.yml, or backend-config.hcl for local use).
  backend "azurerm" {
    key = "staging.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  use_oidc        = true
  # client_id and tenant_id are NOT set here — the provider reads them
  # automatically from ARM_CLIENT_ID / ARM_TENANT_ID environment variables.
  # No client secret is used at all with OIDC.
}

# ---------------------------------------------------------
# Resource Group
# ---------------------------------------------------------
module "rg_staging" {
  source   = "../../modules/resource-group"
  name     = "rg-vnet-staging-uaenorth-01"
  location = var.location
  tags     = var.tags
}

# ---------------------------------------------------------
# Virtual Network
# ---------------------------------------------------------
module "vnet_staging" {
  source              = "../../modules/vnet"
  name                = "vnet-viwell-nonprod-uaenorth-01"
  resource_group_name = module.rg_staging.name
  location            = var.location
  address_space       = ["10.20.0.0/16"]

  subnets = {
    "snet-apps-nonprod-uaenorth-01" = {
      address_prefixes = ["10.20.0.64/26"]
    }
    "snet-funcapp-nonprod-uaenorth-01" = {
      address_prefixes   = ["10.20.2.0/26"]
      delegation_name    = "appservice-delegation"
      delegation_service = "Microsoft.Web/serverFarms"
    }
    "snet-prvtendpt-nonprod-uaenorth-01" = {
      address_prefixes = ["10.20.0.128/26"]
    }
    "snet-db-nonprod-uaenorth-01" = {
      address_prefixes   = ["10.20.0.192/27"]
      delegation_name    = "postgres-delegation"
      delegation_service = "Microsoft.DBforPostgreSQL/flexibleServers"
    }
  }

  tags = var.tags
}

# ---------------------------------------------------------
# ACR
# ---------------------------------------------------------
module "acr_staging" {
  source              = "../../modules/acr"
  name                = "acrviwellnonproduaenorth01"
  resource_group_name = module.rg_staging.name
  location            = var.location
  sku                 = "Standard"
  tags                = var.tags
}

# ---------------------------------------------------------
# AKS
# ---------------------------------------------------------
module "aks_staging" {
  source              = "../../modules/aks"
  name                = "aks-viwell-nonprod-uaenorth-01"
  resource_group_name = module.rg_staging.name
  location            = var.location
  dns_prefix          = "aksviwellnonprod"
  vnet_subnet_id      = module.vnet_staging.subnet_ids["snet-apps-nonprod-uaenorth-01"]
  acr_id              = module.acr_staging.id
  node_count          = 2
  vm_size             = "Standard_D2s_v3"
  tags                = var.tags
}

# ---------------------------------------------------------
# Private DNS Zones (PostgreSQL + Redis)
# ---------------------------------------------------------
module "postgres_dns_zone_staging" {
  source              = "../../modules/private-dns-zone"
  zone_name           = "privatelink.postgres.database.azure.com"
  resource_group_name = module.rg_staging.name
  vnet_id             = module.vnet_staging.vnet_id
  tags                = var.tags
}

module "redis_dns_zone_staging" {
  source              = "../../modules/private-dns-zone"
  zone_name           = "privatelink.redis.cache.windows.net"
  resource_group_name = module.rg_staging.name
  vnet_id             = module.vnet_staging.vnet_id
  tags                = var.tags
}

# ---------------------------------------------------------
# PostgreSQL Flexible Server
# ---------------------------------------------------------
module "postgresql_staging" {
  source                        = "../../modules/postgresql"
  name                          = "psql-viwell-nonprod-uaenorth-01"
  resource_group_name           = module.rg_staging.name
  location                      = var.location
  administrator_login           = var.postgres_administrator_login
  administrator_password        = var.postgres_administrator_password
  delegated_subnet_id           = module.vnet_staging.subnet_ids["snet-db-nonprod-uaenorth-01"]
  private_dns_zone_id           = module.postgres_dns_zone_staging.id
  sku_name                      = "B_Standard_B1ms"
  public_network_access_enabled = var.public_network_access_enabled
  tags                          = var.tags
}

# ---------------------------------------------------------
# Function App
# ---------------------------------------------------------
module "function_app_staging" {
  source               = "../../modules/function-app"
  name                 = "func-viwell-nonprod-uaenorth-01"
  resource_group_name  = module.rg_staging.name
  location             = var.location
  storage_account_name = "stviwellnpuaenorth01"
  vnet_subnet_id       = module.vnet_staging.subnet_ids["snet-funcapp-nonprod-uaenorth-01"]
  tags                 = var.tags
}

# ---------------------------------------------------------
# Redis Cache
# ---------------------------------------------------------
module "redis_staging" {
  source                     = "../../modules/redis"
  name                       = "redis-viwell-nonprod-uaenorth-01"
  resource_group_name        = module.rg_staging.name
  location                   = var.location
  capacity                   = 1
  family                     = "C"
  sku_name                   = "Standard"
  enable_private_endpoint    = true
  private_endpoint_subnet_id = module.vnet_staging.subnet_ids["snet-prvtendpt-nonprod-uaenorth-01"]
  private_dns_zone_ids       = [module.redis_dns_zone_staging.id]
  tags                       = var.tags
}

# ---------------------------------------------------------
# Event Hub
# ---------------------------------------------------------
module "eventhub_staging" {
  source              = "../../modules/eventhub"
  namespace_name      = "evhns-viwell-nonprod-uaenorth-01"
  eventhub_name       = "evh-viwell-nonprod-uaenorth-01"
  resource_group_name = module.rg_staging.name
  location            = var.location
  sku                 = "Standard"
  capacity            = 1
  tags                = var.tags
}
