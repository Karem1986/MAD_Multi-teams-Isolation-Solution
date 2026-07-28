# DATABRICKS GOVERNANCE LAYER: Unity Catalog Access Control

# NOTE: This is a pseudo-Terraform architecture blueprint showcasing the separate 
# data governance layer. It leverages the "databricks" provider to target the 
# individual team workspaces provisioned by our primary infrastructure module.

# DATABRICKS GOVERNANCE LAYER: Unity Catalog Access Control (Post-Provisioning)

# Create the Dedicated Catalog for Team Analytics
resource "databricks_catalog" "analytics_catalog" {
  provider     = databricks.workspace 
  metastore_id = var.central_metastore_id
  name         = "catalog_${var.workload_name}_analytics_${var.environment}"
  comment      = "Isolated data catalog dedicated entirely to Team Analytics workspace tasks."
  storage_root = "abfss://${module.team_slices["analytics"].storage_container_name}@${azurerm_storage_account.mad_storage.name}.dfs.core.windows.net/"
}

# Enforce Strict RBAC Permissions for Team Analytics
resource "databricks_grant" "analytics_permissions" {
  provider     = databricks.workspace 
  catalog    = databricks_catalog.analytics_catalog.name
  principal  = "grp-mad-analytics"
  privileges = ["USE_CATALOG", "CREATE_SCHEMA", "SELECT"]
}

# ------------------------------------------------------------------------------

# Create the Dedicated Catalog for Team Ingest
resource "databricks_catalog" "ingest_catalog" {
  provider     = databricks.workspace # Matches with databricks alias in providers.tf
  metastore_id = var.central_metastore_id
  name         = "catalog_${var.workload_name}_ingest_${var.environment}"
  comment      = "Isolated data catalog dedicated entirely to Team Ingest workflow pipelines."
  storage_root = "abfss://${module.team_slices["ingest"].storage_container_name}@${azurerm_storage_account.mad_storage.name}.dfs.core.windows.net/"
}

# Enforce Strict RBAC Permissions for Team Ingest
resource "databricks_grant" "ingest_permissions" {
  provider     = databricks.workspace
  catalog    = databricks_catalog.ingest_catalog.name
  principal  = "grp-mad-ingest"
  privileges = ["USE_CATALOG", "CREATE_SCHEMA", "MODIFY", "SELECT"]
}
