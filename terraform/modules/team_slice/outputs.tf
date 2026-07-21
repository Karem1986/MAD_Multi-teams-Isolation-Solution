# OUTPUT DEFINITIONS: Azure Databricks Team Onboarding module

output "workspace_id" {
  type        = string
  description = "The unique resource ID of the provisioned Azure Databricks Workspace."
  value       = azurerm_databricks_workspace.team_ws.id
}

output "workspace_url" {
  type        = string
  description = "The workspace public URL needed by users and provisioning tools to access the Databricks UI."
  value       = azurerm_databricks_workspace.team_ws.workspace_url
}

output "storage_container_id" {
  type        = string
  description = "The direct Resource Manager ID of the created team storage container."
  value       = azurerm_storage_container.team_container.id
}

output "storage_container_name" {
  type        = string
  description = "The physical name of the storage container inside the ADLS Gen2 storage account."
  value       = azurerm_storage_container.team_container.name
}

output "unity_connector_id" {
  type        = string
  description = "The Resource ID of the Access Connector for Unity Catalog. Crucial for mapping metastores."
  value       = azurerm_databricks_access_connector.unity_connector.id
}

output "unity_connector_principal_id" {
  type        = string
  description = "The System-Assigned Managed Identity Principal ID of the Access Connector. Used for external IAM mappings."
  value       = azurerm_databricks_access_connector.unity_connector.identity[0].principal_id
}
