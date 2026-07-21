# ROOT CONFIGURATION: MAD Core Shared Infrastructure & Dynamic Team Onboarding

# 1. Core Shared Base Platform Infrastructure

# Shared Central Resource Group
resource "azurerm_resource_group" "mad_rg" {
  name     = "rg-mad-shared-${var.environment}"
  location = var.location
}

# Shared Central ADLS Gen2 Storage Account (Hierarchical Namespace Enabled)

resource "azurerm_storage_account" "mad_storage" {
  name                     = "stmadshared${var.environment}001"
  resource_group_name      = azurerm_resource_group.mad_rg.name
  location                 = azurerm_resource_group.mad_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = true # This activates Hierarchical Namespace (ADLS Gen2), it changes the storage account from a flat object store to a true directory file system. This is a strict pre-requisite for high-performance Delta Lake operations and Unity Catalog integrations in Databricks.
}

# 2. Automation Control Panel: Onboarded Teams Array

locals {
  # To satisfy the "add a 3rd/4th team later" requirement, engineers simply add 
  # strings here. The root module handles everything else dynamically.

  onboarded_teams = toset([
    "analytics",
    "ingest"

  ])
}

# 3. Dynamic Team Slice Provisioning (Consuming Shared Resources)

module "team_slices" {
  source   = "./modules/team_slice"
  for_each = local.onboarded_teams

  team_name            = each.key # Dynamically evaluates to "analytics" then "ingest"
  environment          = var.environment
  location             = azurerm_resource_group.mad_rg.location
  resource_group_name  = azurerm_resource_group.mad_rg.name
  storage_account_name = azurerm_storage_account.mad_storage.name
}
