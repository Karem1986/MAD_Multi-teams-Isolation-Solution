# DATABRICKS GOVERNANCE LAYER: Unity Catalog Access Control

# NOTE: This is a pseudo-Terraform architecture blueprint showcasing the separate 
# data governance layer. It leverages the "databricks" provider to target the 
# individual team workspaces provisioned by our primary infrastructure module.


# ------------------------------------------------------------------------------
# 1. TEAM ANALYTICS DATA GOVERNANCE BOUNDARY
# ------------------------------------------------------------------------------

# Create the Dedicated Catalog for Team Analytics
resource "databricks_catalog" "analytics_catalog" {
  metastore_id = var.central_metastore_id
  name         = "analytics_catalog"
  comment      = "Isolated data catalog dedicated entirely to Team Analytics workspace tasks."
  storage_root = "abfss://cnt-mad-analytics-dev@stmadshareddev001.dfs.core.windows.net/"
}

# Enforce RBAC Permissions for Team Analytics

resource "databricks_grant" "analytics_permissions" {
  catalog    = databricks_catalog.analytics_catalog.name
  principal  = "grp-mad-analytics"
  privileges = ["USE_CATALOG", "CREATE_SCHEMA", "SELECT"]
}

# ------------------------------------------------------------------------------
# 2. TEAM INGEST DATA GOVERNANCE BOUNDARY
# ------------------------------------------------------------------------------

# Create the Dedicated Catalog for Team Ingest

resource "databricks_catalog" "ingest_catalog" {
  metastore_id = var.central_metastore_id
  name         = "ingest_catalog"
  comment      = "Isolated data catalog dedicated entirely to Team Ingest workflow pipelines."
  storage_root = "abfss://cnt-mad-ingest-dev@stmadshareddev001.dfs.core.windows.net/"
}

# Enforce Strict RBAC Permissions for Team Ingest

resource "databricks_grant" "ingest_permissions" {
  catalog    = databricks_catalog.ingest_catalog.name
  principal  = "grp-mad-ingest"
  privileges = ["USE_CATALOG", "CREATE_SCHEMA", "MODIFY", "SELECT"]
}
