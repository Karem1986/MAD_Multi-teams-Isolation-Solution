# REUSABLE MODULE: Azure Databricks Team Onboarding
#SLIDE 5

terraform {
  # Aligned with the root module baseline for version consistency
  required_version = ">= 1.5.0" 

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0" # FIXED: Matches the root module v4.x major release constraint
    }
  }
}

# Local Variables & Naming Conventions

locals {
  prefix = "mad-${var.team_name}-${var.environment}"

  # Standardize tags across all module resources
  common_tags = {
    Environment = var.environment
    Team        = var.team_name
    ManagedBy   = "MAD-Platform-Team"
  }
}

# 1. Team Azure Databricks Workspace

resource "azurerm_databricks_workspace" "team_ws" {
  name                = "dbw-${local.prefix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "premium" # Required for Unity Catalog governance & fine-grained RBAC. Standard or basic workspaces lack the cloud-plane capabilities required to enable fine-grained access control, identity federation and Unity Catalog integrations.

  tags = local.common_tags
}

# 2. Team Storage Container

resource "azurerm_storage_container" "team_container" {
  name                 = "cnt-${local.prefix}"
  storage_account_id = var.storage_account_id # To match with the variable and pass at runtime with terraform plan
  container_access_type = "private" 
}

# 3. Access Connector for Unity Catalog (Managed Identity)

resource "azurerm_databricks_access_connector" "unity_connector" {
  name                = "ac-${local.prefix}"
  resource_group_name = var.resource_group_name
  location            = var.location

  identity {
    type = "SystemAssigned"
  }

  tags = local.common_tags
}

# 4. RBAC: Grant Access Connector permission over the Team Container

resource "azurerm_role_assignment" "access_connector_blob_data_contributor" {
  scope                = azurerm_storage_container.team_container.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_databricks_access_connector.unity_connector.identity[0].principal_id
}
