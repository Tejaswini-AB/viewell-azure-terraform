# Azure Cache for Redis (classic) is being retired by Microsoft in favor of
# Azure Managed Redis (built on Redis Enterprise architecture). This module
# uses azurerm_managed_redis, which supersedes both azurerm_redis_cache and
# azurerm_redis_enterprise_cluster/database.
# See: https://aka.ms/AzureCacheForRedisRetirement

resource "azurerm_managed_redis" "this" {
  name                      = var.name
  resource_group_name       = var.resource_group_name
  location                  = var.location
  sku_name                  = var.sku_name
  high_availability_enabled = var.high_availability_enabled
  # minimum_tls_version       = var.minimum_tls_version
  public_network_access = var.enable_private_endpoint ? "Disabled" : "Enabled"
  tags                  = var.tags

  default_database {
    clustering_policy = var.clustering_policy
    eviction_policy   = var.eviction_policy
  }
}

resource "azurerm_private_endpoint" "this" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = "pep-${var.name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "psc-${var.name}"
    private_connection_resource_id = azurerm_managed_redis.this.id
    subresource_names              = ["redisEnterprise"]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = length(var.private_dns_zone_ids) > 0 ? [1] : []
    content {
      name                 = "${var.name}-dns-group"
      private_dns_zone_ids = var.private_dns_zone_ids
    }
  }
}
