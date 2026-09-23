variable "name" {
  description = "Name of the PostgreSQL Flexible Server"
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

variable "postgres_version" {
  description = "PostgreSQL major version"
  type        = string
  default     = "16"
}

variable "sku_name" {
  description = "SKU name, e.g. GP_Standard_D2s_v3, B_Standard_B1ms"
  type        = string
  default     = "B_Standard_B1ms"
}

variable "storage_mb" {
  description = "Storage size in MB"
  type        = number
  default     = 32768
}

variable "administrator_login" {
  description = "Administrator login name"
  type        = string
}

variable "administrator_password" {
  description = "Administrator login password"
  type        = string
  sensitive   = true
}

variable "delegated_subnet_id" {
  description = "Subnet ID delegated to Microsoft.DBforPostgreSQL/flexibleServers"
  type        = string
}

variable "private_dns_zone_id" {
  description = "Private DNS zone ID for PostgreSQL Flexible Server VNet integration"
  type        = string
}

variable "backup_retention_days" {
  description = "Backup retention in days"
  type        = number
  default     = 7
}

variable "geo_redundant_backup_enabled" {
  description = "Whether geo-redundant backups are enabled"
  type        = bool
  default     = false
}

variable "zone" {
  description = "Primary availability zone for the server, e.g. \"1\""
  type        = string
  default     = null
}

variable "high_availability_enabled" {
  description = "Whether to enable zone-redundant high availability (deploys a standby replica in standby_availability_zone)"
  type        = bool
  default     = false
}

variable "standby_availability_zone" {
  description = "Availability zone for the standby replica, e.g. \"2\". Required if high_availability_enabled is true."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
