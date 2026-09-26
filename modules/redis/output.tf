output "id" {
  description = "Resource ID of the Managed Redis instance"
  value       = azurerm_managed_redis.this.id
}

output "hostname" {
  description = "Hostname of the Managed Redis instance"
  value       = azurerm_managed_redis.this.hostname
}

output "primary_access_key" {
  description = "Primary access key of the default database"
  value       = azurerm_managed_redis.this.default_database[0].primary_access_key
  sensitive   = true
}

output "secondary_access_key" {
  description = "Secondary access key of the default database"
  value       = azurerm_managed_redis.this.default_database[0].secondary_access_key
  sensitive   = true
}

output "private_endpoint_ip" {
  description = "Private IP address assigned to the private endpoint, if created"
  value       = var.enable_private_endpoint ? azurerm_private_endpoint.this[0].private_service_connection[0].private_ip_address : null
}
