variable "name" {
  description = "Name of the Redis Cache (globally unique)"
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

variable "capacity" {
  description = "Cache size. Meaning depends on family: C=[0-6], P=[1-5]"
  type        = number
  default     = 1
}

variable "family" {
  description = "SKU family: C (Basic/Standard) or P (Premium)"
  type        = string
  default     = "C"
}

variable "sku_name" {
  description = "SKU name: Basic, Standard, or Premium"
  type        = string
  default     = "Standard"
}

variable "minimum_tls_version" {
  description = "Minimum TLS version accepted by the cache"
  type        = string
  default     = "1.2"
}

variable "public_network_access_enabled" {
  description = "Whether public network access is allowed. Set false when using a private endpoint."
  type        = bool
  default     = true
}

variable "zones" {
  description = "Availability zones for the cache, e.g. [\"1\",\"2\",\"3\"]. Only supported on Premium SKU."
  type        = list(string)
  default     = []
}

variable "enable_private_endpoint" {
  description = "Whether to create a private endpoint for this cache"
  type        = bool
  default     = false
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID to deploy the private endpoint into (required if enable_private_endpoint is true)"
  type        = string
  default     = null
}

variable "private_dns_zone_ids" {
  description = "Private DNS zone IDs to link the private endpoint's DNS record to (privatelink.redis.cache.windows.net)"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
