terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.0"
    }
  }
}

provider "azurerm" {
  resource_provider_registrations = "extended"
  features {
    resource_group {
      # It Prevents automated state destructions if a 
      # shared resource group contains live, active data platform assets.
      prevent_deletion_if_contains_resources = true
    }
  }
}

# The Databricks provider configuration block will dynamically initialize 
# via environment parameters or workspace connection configurations during live deployment.
# SLIDE 6
provider "databricks" {
  alias = "workspace"
  #NO HOST YET
}