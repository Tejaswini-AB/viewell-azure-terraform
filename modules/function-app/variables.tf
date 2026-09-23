variable "name" {
  description = "Name of the Function App"
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

variable "storage_account_name" {
  description = "Name of the storage account backing the Function App (must be globally unique, lowercase alphanumeric)"
  type        = string
}

variable "service_plan_sku" {
  description = "SKU for the App Service Plan, e.g. Y1 (consumption), EP1 (premium)"
  type        = string
  default     = "Y1"
}

variable "os_type" {
  description = "OS type for the service plan: Linux or Windows"
  type        = string
  default     = "Linux"
}

variable "app_settings" {
  description = "App settings (environment variables) for the Function App"
  type        = map(string)
  default     = {}
}

variable "vnet_subnet_id" {
  description = "Subnet ID for VNet integration (optional)"
  type        = string
  default     = null
}

variable "storage_account_replication_type" {
  description = "Replication type for the backing storage account: LRS, ZRS, GRS, GZRS, etc."
  type        = string
  default     = "LRS"
}

variable "zone_balancing_enabled" {
  description = "Whether to zone-balance the App Service Plan across availability zones. Requires a Premium v2/v3 or Elastic Premium SKU (not Y1/Consumption)."
  type        = bool
  default     = false
}

variable "service_plan_worker_count" {
  description = "Number of workers/instances for the App Service Plan. When zone_balancing_enabled is true, this is forced to at least 2 (Azure spreads them across zones)."
  type        = number
  default     = 1
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
