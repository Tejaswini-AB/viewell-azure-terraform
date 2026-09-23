variable "name" {
  description = "Name of the virtual network (e.g. vnet-viwell-hub-uaenorth-01)"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group in which to create the VNet"
  type        = string
}

variable "location" {
  description = "Azure region for the virtual network"
  type        = string
}

variable "address_space" {
  description = "Address space of the virtual network, e.g. [\"10.10.0.0/16\"]"
  type        = list(string)
}

variable "subnets" {
  description = <<-EOT
    Map of subnets to create, keyed by subnet name. Each value supports:
      address_prefixes    - required, list(string)
      service_endpoints   - optional, list(string)
      delegation_name     - optional, string, name of the delegation block
      delegation_service  - optional, string, e.g. "Microsoft.DBforPostgreSQL/flexibleServers"
  EOT
  type = map(object({
    address_prefixes   = list(string)
    service_endpoints  = optional(list(string), [])
    delegation_name    = optional(string)
    delegation_service = optional(string)
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply to the virtual network"
  type        = map(string)
  default     = {}
}
