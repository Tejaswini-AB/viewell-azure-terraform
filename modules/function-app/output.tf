output "id" {
  description = "Resource ID of the Function App"
  value       = azurerm_windows_function_app.this.id
}

output "name" {
  description = "Name of the Function App"
  value       = azurerm_windows_function_app.this.name
}

output "default_hostname" {
  description = "Default hostname of the Function App"
  value       = azurerm_windows_function_app.this.default_hostname
}
