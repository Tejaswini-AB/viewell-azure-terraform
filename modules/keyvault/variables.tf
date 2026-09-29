variable "name" {
  description = "Name of the Managed Redis instance (globally unique)"
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

variable "sku_name" {
  description = "SKU for Azure Managed Redis, e.g. Balanced_B0, Balanced_B1, Balanced_B3, MemoryOptimized_M10, ComputeOptimized_X5, FlashOptimized_A250. NOTE: Enterprise_*/EnterpriseFlash_* SKUs (old Redis Enterprise naming) are NOT valid here."
  type        = string
  default     = "Balanced_B0"
}

variable "high_availability_enabled" {
  description = "Whether zone/node redundant high availability is enabled"
  type        = bool
  default     = false
}

variable "clustering_policy" {
  description = "Clustering policy for the default database: EnterpriseCluster, OSSCluster, or NoCluster"
  type        = string
  default     = "EnterpriseCluster"
}

variable "eviction_policy" {
  description = "Eviction policy for the default database: AllKeysLRU, AllKeysRandom, VolatileLRU, VolatileTTL, NoEviction, etc."
  type        = string
  default     = "VolatileLRU"
}

variable "minimum_tls_version" {
  description = "Minimum TLS version accepted by the cache"
  type        = string
  default     = "1.2"
}

variable "enable_private_endpoint" {
  description = "Whether to create a private endpoint for this cache. When true, public_network_access is forced to Disabled."
  type        = bool
  default     = false
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID to deploy the private endpoint into (required if enable_private_endpoint is true)"
  type        = string
  default     = null
}

variable "private_dns_zone_ids" {
  description = "Private DNS zone IDs to link the private endpoint's DNS record to (privatelink.redisenterprise.cache.azure.net — VERIFY this zone name against current Azure docs before first apply, as it may differ from the legacy privatelink.redis.cache.windows.net used by classic Azure Cache for Redis)"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}

variable "tenant_id" {
  type = string
}