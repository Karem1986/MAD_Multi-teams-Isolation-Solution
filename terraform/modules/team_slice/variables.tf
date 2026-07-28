# INPUT VARIABLES: Azure Databricks Team Onboarding Module

variable "team_name" {
  type        = string
  description = "The name of the team being onboarded (e.g., marketing, finance). Must be alphanumeric and lowercase."

  # To prevent Pipeline deployment failures:
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.team_name))
    error_message = "The team_name variable must contain only lowercase alphanumeric characters or hyphens."
  }
}

variable "environment" {
  type        = string
  description = "Target deployment environment (e.g., dev, tst, prod)."
  default     = "dev"

  validation {
    condition     = contains(["dev", "tst", "stg", "prod"], var.environment)
    error_message = "The environment variable must be one of: dev, tst, stg, prod."
  }
}

variable "storage_account_id" {
  type        = string
  description = "The resource ID of the shared ADLS Gen2 Storage Account."
}

variable "location" {
  type        = string
  description = "The target Azure Region where regional resources will be provisioned."
  default     = "westeurope"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the pre-existing shared Resource Group."
}

variable "storage_account_name" {
  type        = string
  description = "The name of the pre-existing shared ADLS Gen2 Storage Account."
}
