variable "subscription_id" {
  description = "Azure subscription ID for production"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "uaenorth"
}

variable "postgres_administrator_login" {
  description = "PostgreSQL administrator login"
  type        = string
  default     = "psqladmin"
}

variable "postgres_administrator_password" {
  description = "PostgreSQL administrator password (pass via TF_VAR_ or a gitignored *.tfvars, never hardcoded)"
  type        = string
  sensitive   = true
}

variable "postgres_private_dns_zone_id" {
  description = "Private DNS zone ID for PostgreSQL Flexible Server (e.g. privatelink.postgres.database.azure.com)"
  type        = string
}

variable "redis_private_dns_zone_ids" {
  description = "Private DNS zone IDs for the Redis private endpoint (privatelink.redis.cache.windows.net)"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default = {
    environment = "production"
    managed_by  = "terraform"
  }
}
