# How to Run Guide

This guide provides step-by-step instructions to deploy and run the Healthcare RCM Data Platform.

## Prerequisites
- Azure Subscription
- Terraform CLI
- Azure CLI (`az`)

- Python 3.11+

## Step 1: Infrastructure Deployment (Terraform)

1. **Login to Azure**:
   ```bash
   az login
   ```

2. **Initialize and Apply Terraform**:
   ```bash
   cd terraform/environments/dev
   terraform init
   terraform plan
   terraform apply
   ```

## Step 2: Running the Pipeline
1. Log in to the Azure Portal and navigate to Azure Data Factory.
2. Open Data Factory Studio.
3. Trigger the ingestion pipelines manually or wait for the schedule.
4. Monitor the execution in ADF Studio and check pipeline run logs for validation results.
