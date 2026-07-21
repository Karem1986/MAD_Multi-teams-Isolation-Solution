
# DATABRICKS GOVERNANCE LAYER: Unity Catalog Access Control

# Note: This uses the "databricks" provider, targeting the workspace URLs
# exported by our core infrastructure module.

# 1. Create the Isolated Catalog for Team Analytics
resource "databricks_catalog" "analytics_catalog" {
  metastore_id = var.central_metastore_id
  name         = "analytics_catalog"
  comment      = "Isolated data catalog dedicated entirely to Team Analytics"
  
  # References the Access Connector storage credential built by Terraform
  storage_root = "abfss://cnt-mad-analytics-dev@stmadshareddev001.dfs.core.windows.net/"
}

# 2. Enforce Strict RBAC Permissions for Team Analytics
resource "databricks_grant" "analytics_permissions" {
  catalog = databricks_catalog.analytics_catalog.name

  # Grant fine-grained, secure access boundaries exclusively to the Entra ID group
  grant {
    principal  = "grp-mad-analytics"
    privileges = ["USE_CATALOG", "CREATE_SCHEMA", "SELECT"]
  }
}


# 3. Create the Isolated Catalog for Team Ingest
resource "databricks_catalog" "ingest_catalog" {
  metastore_id = var.central_metastore_id
  name         = "ingest_catalog"
  comment      = "Isolated data catalog dedicated entirely to Team Ingest"
  storage_root = "abfss://cnt-mad-ingest-dev@stmadshareddev001.dfs.core.windows.net/"
}

# 4. Enforce Strict RBAC Permissions for Team Ingest
resource "databricks_grant" "ingest_permissions" {
  catalog = databricks_catalog.ingest_catalog.name

  grant {
    principal  = "grp-mad-ingest"
    # Team Ingest builds pipelines, so they require full data modification rights
    privileges = ["USE_CATALOG", "CREATE_SCHEMA", "MODIFY", "SELECT"]
  }
}
