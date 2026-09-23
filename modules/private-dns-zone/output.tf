output "id" {
  description = "Resource ID of the private DNS zone"
  value       = azurerm_private_dns_zone.this.id
}

output "name" {
  description = "Name of the private DNS zone"
  value       = azurerm_private_dns_zone.this.name
}
