# ROOT CONFIGURATION: Dynamic Multi-Team Infrastructure Outputs

output "shared_resource_group_name" {
  description = "The name of the centralized platform resource group."
  value       = azurerm_resource_group.mad_rg.name
}

output "shared_storage_account_name" {
  description = "The name of the shared ADLS Gen2 storage account."
  value       = azurerm_storage_account.mad_storage.name
}

output "onboarded_teams_workspaces" {
  description = "A dynamic map tracking every onboarded team to its dedicated Databricks Workspace URL."
  value = {
    for team, details in module.team_slices : team => details.workspace_url
  }
}

output "onboarded_teams_containers" {
  description = "A dynamic map tracking every onboarded team to its dedicated storage data boundary."
  value = {
    for team, details in module.team_slices : team => details.storage_container_name
  }
}
