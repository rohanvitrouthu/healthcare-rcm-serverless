# Configuring the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.85.0, < 4.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0.0"
    }
  }
  required_version = ">=1.5.0"
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

# Variables
variable "project_name" {
  description = "Project name prefix"
  default     = "rcmdata"
}

variable "environment" {
  description = "Environment name"
  default     = "dev"
}

variable "location" {
  description = "Azure region"
  default     = "westus2"
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "rg-${var.project_name}-${var.environment}"
  location = var.location

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

resource "random_password" "sql_admin" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

module "storage" {
  source = "../../modules/storage"

  # Passing variables in ../../modules/storage/variables.tf to this module
  project_name        = var.project_name
  environment         = var.environment
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  # Optional overrides
  account_replication_type = "LRS"
  containers               = ["landing", "bronze", "silver", "gold", "configs"]

  tags = {
    CostCenter = "DataEngineering"
    Owner      = "DataTeam"
  }
}

# SQL Modules
module "sql_hospital_a" {
  source = "../../modules/sql-database"

  server_name         = "sql-hosp-a-${var.project_name}-${var.environment}-${var.location}"
  database_name       = "HospitalA_DB"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  admin_username      = "sqladmin"
  admin_password      = random_password.sql_admin.result
  allow_all_ips       = true

  tags = {
    CostCenter  = "DataEngineering"
    Environment = var.environment
    Project     = var.project_name
    Hospital    = "HospitalA"
  }
}

module "sql_hospital_b" {
  source = "../../modules/sql-database"

  server_name         = "sql-hosp-b-${var.project_name}-${var.environment}-${var.location}"
  database_name       = "HospitalB_DB"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  admin_username      = "sqladmin"
  admin_password      = random_password.sql_admin.result
  allow_all_ips       = true

  tags = {
    CostCenter  = "DataEngineering"
    Environment = var.environment
    Project     = var.project_name
    Hospital    = "HospitalB"
  }
}

# Key-Vault Module
module "key_vault" {
  source = "../../modules/key-vault"

  project_name        = var.project_name
  environment         = var.environment
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  # Enterprise Configuration
  sku_name                    = "standard"
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false # Please set to true in production.
  enabled_for_disk_encryption = true

  # Network access (Adjust the below for production)
  public_network_access_enabled = true

  # Secrets to store
  secrets = {
    "storage-account-name"      = module.storage.storage_account_name
    "storage-account-key"       = module.storage.primary_access_key
    "storage-connection-string" = module.storage.primary_connection_string
    "storage-dfs-endpoint"      = module.storage.primary_dfs_endpoint
    "sql-password"              = random_password.sql_admin.result
    "sql-conn-str-hosp-a"       = module.sql_hospital_a.connection_string
    "sql-conn-str-hosp-b"       = module.sql_hospital_b.connection_string
  }

  tags = {
    CostCenter = "DataEngineering"
    Compliance = "HIPAA"
  }

  depends_on = [module.storage, module.sql_hospital_a, module.sql_hospital_b]
}

# Azure Data Factory Module
module "data_factory" {
  source = "../../modules/data-factory"

  data_factory_name   = "adf-${var.project_name}-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  
  key_vault_id             = module.key_vault.key_vault_id
  databricks_workspace_url = module.databricks.workspace_url
  databricks_workspace_id  = module.databricks.workspace_id

  tags = {
    CostCenter  = "DataEngineering"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Databricks Module
module "databricks" {
  source = "../../modules/databricks"

  workspace_name      = "dbw-${var.project_name}-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  sku                 = "standard"

  tags = {
    CostCenter  = "DataEngineering"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Allow Data Factory to read secrets from Key Vault
resource "azurerm_role_assignment" "adf_kv_secrets_user" {
  scope                = module.key_vault.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.data_factory.data_factory_principal_id

  depends_on = [module.key_vault, module.data_factory]
}

# Outputs
output "storage_account_name" {
  value = module.storage.storage_account_name
}

output "storage_account_id" {
  value = module.storage.storage_account_id
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "primary_dfs_endpoint" {
  description = "Data Lake Gen2 endpoint"
  value       = module.storage.primary_dfs_endpoint
}

output "key_vault_name" {
  description = "Name of the key vault"
  value       = module.key_vault.key_vault_name
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = module.key_vault.key_vault_uri
}

output "data_factory_name" {
  description = "Name of the Azure Data Factory"
  value       = module.data_factory.data_factory_name
}

output "data_factory_id" {
  description = "ID of the Azure Data Factory"
  value       = module.data_factory.data_factory_id
}

output "databricks_workspace_url" {
  description = "URL of the Databricks Workspace"
  value       = module.databricks.workspace_url
}

output "sql_hospital_a_server_name" {
  value = module.sql_hospital_a.server_name
}

output "sql_hospital_b_server_name" {
  value = module.sql_hospital_b.server_name
}