# Access Separation for multiple teams: The What, How and Why

![MAD_Terri_Architecture_Layers_Design](diagrams/MAD_Terri_Architecture_Layers_Design.png)

## Storage and Insfrastructure level

Within Azure, there is a central Storage Account (ADLS Gen2) that contains 2 isolated containers per team: team-analytics-data, team-ingest-data.

## Databricks Workspace level - Connecting to Azure

Each team has its own Azure Databricks Workspace.

At the top level, there is a single Shared Microsoft Entra ID Tenant, which is standard enterprise practice for central identity management.However, to enforce strict team isolation, I created dedicated Entra ID Security Groups per team, one for Team Analytics and one for Team Ingest.
Microsoft Entra ID (Azure AD) Groups are created per team: grp-mad-analytics and grp-mad-ingest.

Team members are assigned ONLY to their team’s workspace. Team Analytics members cannot log into the Ingest workspace, completely isolating notebooks, workflows, and job runs.

Two key enforcements:

1. Workspace Level: Only members of grp-mad-analytics can log into the Analytics Databricks Workspace.

2. Unity Catalog Level: We assign data permissions explicitly to the groups. analytics_catalog grants access only to grp-mad-analytics, ensuring full data and code separation even though they share the underlying tenant and cloud subscription.

## Data and Governance Level - Unity Catalog

A single, centralized Unity Catalog Metastore governs data assets. Each team owns a dedicated Catalog (analytics_catalog, ingest_catalog).

Unity Catalog explicit GRANT statements enforce data boundaries:

  'GRANT USE CATALOG, CREATE SCHEMA ON CATALOG analytics_catalog TO grp-mad-analytics'

Thus, Members of grp-mad-ingest have zero permissions on analytics_catalog.

## Reusable Terraform Module: How easy it would be to add a third team later by reusing the same module

The goal is to build a reusable Terraform Module locally executable (terraform plan ready).

## Databricks Production-grade Pyspark Job

A databricks notebook with pyspark small jobs to: read data from the source, delete duplicates/check for nulls and save the cleaned data to a delta lake table.

## Additional Notes

AI was utilized as an engineering co-pilot to assist with generating base Terraform boilerplate syntax, PySpark unit testing patterns, and structuring Markdown documentation. 
All architecture choices, security boundaries, and code implementations were reviewed and tailored to meet Ahold Delhaize MAD standards.

## Future Steps - What I would do with more time

I would build CI/CD automations with GitHub Actions pipelines for automated terraform plan/apply and PyTest executions on Pull Requests.
