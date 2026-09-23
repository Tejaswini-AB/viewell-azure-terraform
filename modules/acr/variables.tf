variable "name" {
  description = "Name of the Azure Container Registry (must be globally unique, alphanumeric only)"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "sku" {
  description = "ACR SKU: Basic, Standard, or Premium"
  type        = string
  default     = "Standard"
}

variable "zone_redundancy_enabled" {
  description = "Whether zone redundancy is enabled. Only supported on Premium SKU."
  type        = bool
  default     = false
}

variable "admin_enabled" {
  description = "Whether the ACR admin account is enabled"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
