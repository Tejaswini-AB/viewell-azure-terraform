output "namespace_id" {
  description = "Resource ID of the Event Hub Namespace"
  value       = azurerm_eventhub_namespace.this.id
}

output "eventhub_id" {
  description = "Resource ID of the Event Hub"
  value       = azurerm_eventhub.this.id
}
