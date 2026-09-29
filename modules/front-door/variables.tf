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

variable "origin_groups" {
  description = <<-EOT
    Map of backend targets to front, keyed by a short name (e.g. "aks_staging",
    "func_staging"). Each creates its own origin group + origin + route.
  EOT
  type = map(object({
    host_name                      = string
    http_port                      = optional(number, 80)
    https_port                     = optional(number, 443)
    priority                       = optional(number, 1)
    weight                         = optional(number, 500)
    certificate_name_check_enabled = optional(bool, true)
    path_patterns                  = list(string)
    forwarding_protocol            = optional(string, "HttpsOnly")
  }))
}

variable "waf_mode" {
  description = "Prevention (blocks matched requests) or Detection (logs only)"
  type        = string
  default     = "Prevention"
}

variable "enable_managed_waf_rules" {
  description = "Enable Microsoft-managed WAF rule sets (DefaultRuleSet + BotManagerRuleSet). Requires Premium_AzureFrontDoor SKU."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
