output "id" {
  description = "Resource ID of the Redis Cache"
  value       = azurerm_redis_cache.this.id
}

output "hostname" {
  description = "Hostname of the Redis Cache"
  value       = azurerm_redis_cache.this.hostname
}

output "ssl_port" {
  description = "SSL port of the Redis Cache"
  value       = azurerm_redis_cache.this.ssl_port
}

output "primary_access_key" {
  description = "Primary access key"
  value       = azurerm_redis_cache.this.primary_access_key
  sensitive   = true
}

output "primary_connection_string" {
  description = "Primary connection string"
  value       = azurerm_redis_cache.this.primary_connection_string
  sensitive   = true
}

output "private_endpoint_ip" {
  description = "Private IP address assigned to the private endpoint, if created"
  value       = var.enable_private_endpoint ? azurerm_private_endpoint.this[0].private_service_connection[0].private_ip_address : null
}
