variable "name" {
  description = "Name of the AKS cluster"
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

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = null
}

variable "node_pool_name" {
  description = "Name of the default node pool"
  type        = string
  default     = "default"
}

variable "node_count" {
  description = "Number of nodes in the default node pool"
  type        = number
  default     = 2
}

variable "vm_size" {
  description = "VM size for the default node pool"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "vnet_subnet_id" {
  description = "Subnet ID for the AKS default node pool"
  type        = string
}

variable "availability_zones" {
  description = "Availability zones for the default node pool, e.g. [\"1\",\"2\",\"3\"]. Empty list disables zone pinning."
  type        = list(string)
  default     = []
}

variable "acr_id" {
  description = "ACR resource ID to grant AcrPull to the AKS kubelet identity (leave null to skip)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
