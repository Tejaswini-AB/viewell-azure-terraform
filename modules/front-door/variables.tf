variable "profile_name" {
  description = "Name of the Front Door profile"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "sku_name" {
  description = "Standard_AzureFrontDoor or Premium_AzureFrontDoor. Premium is required for Microsoft-managed WAF rule sets (bot protection, OWASP managed rules); Standard only supports custom WAF rules."
  type        = string
  default     = "Premium_AzureFrontDoor"
}

variable "endpoint_name" {
  description = "Name of the Front Door endpoint (becomes part of the *.azurefd.net hostname)"
  type        = string
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
