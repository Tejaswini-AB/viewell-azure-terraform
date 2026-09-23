resource "azurerm_storage_account" "this" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = var.storage_account_replication_type
  tags                     = var.tags
}

resource "azurerm_service_plan" "this" {
  name                    = "${var.name}-plan"
  resource_group_name    = var.resource_group_name
  location                = var.location
  os_type                 = var.os_type
  sku_name                = var.service_plan_sku
  worker_count            = var.zone_balancing_enabled ? max(var.service_plan_worker_count, 2) : var.service_plan_worker_count
  zone_balancing_enabled  = var.zone_balancing_enabled
  tags                    = var.tags
}

resource "azurerm_linux_function_app" "this" {
  name                       = var.name
  resource_group_name        = var.resource_group_name
  location                   = var.location
  service_plan_id            = azurerm_service_plan.this.id
  storage_account_name       = azurerm_storage_account.this.name
  storage_account_access_key = azurerm_storage_account.this.primary_access_key
  app_settings                = var.app_settings
  virtual_network_subnet_id  = var.vnet_subnet_id
  tags                        = var.tags

  site_config {}
}
