# ROOT CONFIGURATION: MAD Core Shared Infrastructure & Dynamic Team Onboarding

# Centralized naming convention configuration to address hardcoded structures
locals {
  # Standardize region shorts (e.g., westeurope -> weu) to prevent long resource strings
  location_short = var.location == "westeurope" ? "weu" : "glob"
  
  # Standardize core platform identifier prefix
  prefix         = "mad-shared-${var.environment}-${local.location_short}"

  # Safe, sanitized naming convention for storage accounts (Strict max 24 character Azure limit)
  # Uses 3 arguments for replace() to strip out hyphens and forces completely lowercase
  storage_name   = substr(lower(replace("stmadshared${var.environment}${local.location_short}001", "-", "")), 0, 24)
}

# 1. Core Shared Base Platform Infrastructure

# Shared Central Resource Group
resource "azurerm_resource_group" "mad_rg" {
  name     = "rg-${local.prefix}"
  location = var.location
}

# Shared Central ADLS Gen2 Storage Account (Hierarchical Namespace Enabled)
resource "azurerm_storage_account" "mad_storage" {
  name                     = local.storage_name
  resource_group_name      = azurerm_resource_group.mad_rg.name
  location                 = azurerm_resource_group.mad_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = true # This activates Hierarchical Namespace (ADLS Gen2), it changes the storage account from a flat object store to a true directory file system. This is a strict pre-requisite for high-performance Delta Lake operations and Unity Catalog integrations in Databricks.
}

# 2. Adding more teams dinamically with the reusable child module

locals {
  # To satisfy the "add a 3rd/4th team later" requirement, engineers simply add 
  # the new team here. The root module handles everything else dynamically.

  onboarded_teams = toset([
    "analytics",
    "ingest"
  ])
}

# 3. Dynamic Team Slice Provisioning (Consuming Shared Resources)

module "team_slices" {
  source = "./modules/team_slice"

  # Declarative metadata loop to dynamically provision isolated environments.

  for_each = local.onboarded_teams

  team_name            = each.key # Dynamically evaluates to "analytics" then "ingest"
  environment          = var.environment
  location             = azurerm_resource_group.mad_rg.location
  resource_group_name  = azurerm_resource_group.mad_rg.name
  storage_account_name = azurerm_storage_account.mad_storage.name
}
