# How to run Terraform locally

- Navigate to the root directory Terraform folder:

   ```cd terraform/```

- Initialize the provider plugins locally:

```terraform init -backend=false```

*Note:*Because this is for a demo/presentation and we are not deploying live resources, run terraform init with the -backend=false downloads the latest azurerm provider binaries onto the machine without demanding an active Azure login session.

- Run the code format cleanup:

```terraform fmt -recursive```

- Confirm your files have zero typos or reference mistakes:

```terraform validate```

*Expected Output:* `Success! The configuration is valid.`

![Terraform Validate Success](diagrams/Terraform_Validate_Success.png)

-Live `terraform plan` dry-runs are designed to target a running Azure Tenant control plane and are omitted locally to maintain offline code portability without hardcoding tenant tokens.
