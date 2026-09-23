variable "zone_name" {
  description = "Private DNS zone name, e.g. privatelink.postgres.database.azure.com"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group in which to create the private DNS zone"
  type        = string
}

variable "vnet_id" {
  description = "VNet ID to link this private DNS zone to"
  type        = string
}

variable "registration_enabled" {
  description = "Whether auto-registration of VM DNS records is enabled on the link (leave false for PaaS private endpoints/VNet-integration scenarios)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
