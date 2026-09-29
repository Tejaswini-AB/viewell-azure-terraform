resource "azurerm_key_vault" "this" {
  name                          = "kv-viewell-uaenorth-01"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  sku_name                      = var.sku_name
  enable_rbac_authorization     = true
  public_network_access_enabled = false
  tenant_id                     = var.tenant_id
}

resource "azurerm_private_endpoint" "keyvault" {
  name                = "privatelink.keyvault.database.azure.com"
  location            = "pe-${var.name}"
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "pe-${var.name}"
    private_connection_resource_id = azurerm_key_vault.this.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }
}