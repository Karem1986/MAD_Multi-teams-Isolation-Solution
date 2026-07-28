# ROOT CONFIGURATION: Global Input Variable Declarations

variable "environment" {
  type        = string
  description = "Target deployment environment (e.g., dev, tst, prod)."
}

variable "location" {
  type        = string
  description = "The target Azure Region where the central infrastructure will live."
}

variable "workload_name" {
  type        = string
  description = "The overarching platform or application name baseline."
  default     = "mad"
}

variable "central_metastore_id" {
  type        = string
  description = "The global corporate Unity Catalog Metastore identifier required by governance assets."
  default     = "metastore-0000-0000-0000" # Provided safe fallback default for offline blueprint compliance
}