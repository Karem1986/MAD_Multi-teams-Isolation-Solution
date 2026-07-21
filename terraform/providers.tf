# ROOT CONFIGURATION: Production-Hardened Provider Setup & Security Rules

terraform {
  # Enforces a modern Terraform CLI engine baseline
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0" # Targets modern v4.x features
    }
  }
}

provider "azurerm" {
  # PRODUCTION PLATFORM STANDARD: Broadly registers required APIs 
  # (Databricks, Managed Identities, Storage) during initial tenancy deployment.
  resource_provider_registrations = "extended"

  features {
    resource_group {
      # SECURITY CIRCUIT BREAKER: Prevents automated state destructions if a 
      # shared resource group contains live, active data platform assets.
      prevent_deletion_if_contains_resources = true
    }
  }
}
