# ROOT CONFIGURATION: Global Input Variable Declarations

variable "environment" {
  type        = string
  description = "Target deployment environment (e.g., dev, tst, prod)."
}

variable "location" {
  type        = string
  description = "The target Azure Region where the central infrastructure will live."
}
