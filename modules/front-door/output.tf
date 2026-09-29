output "endpoint_hostname" {
  description = "The *.azurefd.net hostname assigned to the Front Door endpoint"
  value       = azurerm_cdn_frontdoor_endpoint.this.host_name
}

output "profile_id" {
  value = azurerm_cdn_frontdoor_profile.this.id
}
