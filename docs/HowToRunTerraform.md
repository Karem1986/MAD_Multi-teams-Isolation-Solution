# How to run Terraform locally

- Navigate to the root directory Terraform folder:

   ```cd terraform/```

- Initialize the provider plugins locally:

```terraform init -backend=false```

*Note:* Because this is for a demo/presentation and we are not deploying live resources, run terraform init with the -backend=false downloads the latest azurerm provider binaries onto the machine without demanding an active Azure login session.

- Run the code format cleanup:

```terraform fmt -recursive```

- Confirm your files have zero typos or reference mistakes:

```terraform validate```

*Expected Output:* `Success! The configuration is valid.`

![Terraform Validate Success](/diagrams/Terraform_Validate_Success.png)

*Important Notes*:

-Live `terraform plan` dry-runs are designed to target a Live Azure Tenant control plane and are omitted locally to maintain offline code portability without hardcoding tenant tokens.

- One alternative to run a 'terraform plan' successfully targeting only the provisioned infrastructure would be to use the -target flag:

```terraform plan -target=module.team_slices -target=azurerm_resource_group.mad_rg -target=azurerm_storage_account.mad_storage```

- The databricks_* resources would fail the plan. The Databricks provider has no host configured. When terraform plan reaches databricks_catalog and databricks_grant, the provider tries to connect to a workspace endpoint and has nowhere to go. It would throw an error that can be solved one we get the databricks catalog and workspaces up and running.
