variable "namespace_name" {
  description = "Name of the Event Hub Namespace"
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
  description = "Event Hub Namespace SKU: Basic, Standard, or Premium"
  type        = string
  default     = "Standard"
}

variable "capacity" {
  description = "Throughput units for the namespace"
  type        = number
  default     = 1
}

variable "eventhub_name" {
  description = "Name of the Event Hub within the namespace"
  type        = string
}

variable "partition_count" {
  description = "Number of partitions"
  type        = number
  default     = 2
}

variable "message_retention" {
  description = "Message retention in days"
  type        = number
  default     = 1
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
