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
  # (see .github/workflows/terraform-global.yml, or backend-config.hcl locally).
  backend "azurerm" {
    key = "global.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  use_oidc        = true
}

# ---------------------------------------------------------
# Remote state reads — this environment is deployed AFTER hub, staging,
# and production, since Front Door origins point at resources those
# environments create. Deploy order: hub -> staging/production -> global.
# ---------------------------------------------------------
data "terraform_remote_state" "hub" {
  backend = "azurerm"
  config = {
    resource_group_name  = "rg-tfstate-uaenorth-01"
    storage_account_name = "sttfstateuaenorth01"
    container_name       = "tfstate"
    key                  = "hub.terraform.tfstate"
  }
}

data "terraform_remote_state" "staging" {
  backend = "azurerm"
  config = {
    resource_group_name  = "rg-tfstate-uaenorth-01"
    storage_account_name = "sttfstateuaenorth01"
    container_name       = "tfstate"
    key                  = "staging.terraform.tfstate"
  }
}

data "terraform_remote_state" "production" {
  backend = "azurerm"
  config = {
    resource_group_name  = "rg-tfstate-uaenorth-01"
    storage_account_name = "sttfstateuaenorth01"
    container_name       = "tfstate"
    key                  = "production.terraform.tfstate"
  }
}

# ---------------------------------------------------------
# Resource Group for global/shared resources
# ---------------------------------------------------------
module "rg_global" {
  source   = "../../modules/resource-group"
  name     = "rg-viwell-global-uaenorth-01"
  location = var.location
  tags     = var.tags
}

# ---------------------------------------------------------
# Azure Front Door (Premium) — fronts the Function Apps in both
# environments with a global WAF. AKS origins are NOT included yet: that
# requires a real public ingress hostname (e.g. an Application Gateway or
# LoadBalancer-type Service in front of AKS), which this repo does not
# provision yet. Add AKS origin_groups entries once that ingress exists —
# note the "/*" pattern on prod currently catches everything, so a more
# specific pattern (e.g. "/api/*") should be used once AKS is added, to
# avoid the two origin groups' path patterns overlapping ambiguously.
# ---------------------------------------------------------
module "front_door" {
  source              = "../../modules/front-door"
  profile_name        = "fd-viwell-uaenorth-01"
  resource_group_name = module.rg_global.name
  endpoint_name       = "viwell"
  sku_name            = "Premium_AzureFrontDoor"

  origin_groups = {
    func_staging = {
      host_name     = data.terraform_remote_state.staging.outputs.function_app_hostname
      path_patterns = ["/staging/*"]
    }
    func_prod = {
      host_name     = data.terraform_remote_state.production.outputs.function_app_hostname
      path_patterns = ["/*"]
    }
  }

  tags = var.tags
}
