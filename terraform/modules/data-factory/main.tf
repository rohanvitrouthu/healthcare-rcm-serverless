resource "azurerm_data_factory" "adf" {
  name                = var.data_factory_name
  location            = var.location
  resource_group_name = var.resource_group_name

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# Key Vault Linked Service
resource "azurerm_data_factory_linked_service_key_vault" "kv" {
  name                = "LS_KeyVault"
  data_factory_id     = azurerm_data_factory.adf.id
  key_vault_id        = var.key_vault_id
}

# Azure SQL Database Linked Service
resource "azurerm_data_factory_linked_service_azure_sql_database" "sql_db" {
  name              = "LS_AzureSqlDatabase"
  data_factory_id   = azurerm_data_factory.adf.id
  connection_string = "Integrated Security=False;Data Source=@{linkedService().db_server}.database.windows.net;Initial Catalog=@{linkedService().db_name};User ID=@{linkedService().db_user}"

  parameters = {
    db_server = ""
    db_name   = ""
    db_user   = "sqladmin"
  }

  key_vault_password {
    linked_service_name = azurerm_data_factory_linked_service_key_vault.kv.name
    secret_name         = "sql-password"
  }
}

# Azure SQL Database Dataset
resource "azurerm_data_factory_dataset_azure_sql_table" "sql_dataset" {
  name                = "DS_AzureSqlTable"
  data_factory_id     = azurerm_data_factory.adf.id
  linked_service_id   = azurerm_data_factory_linked_service_azure_sql_database.sql_db.id

  parameters = {
    schema_name = ""
    table_name  = ""
  }

  schema = "@dataset().schema_name"
  table  = "@dataset().table_name"
}

# ADLS Gen 2 Linked Service
resource "azurerm_data_factory_linked_service_data_lake_storage_gen2" "adls" {
  name                  = "LS_ADLSGen2"
  data_factory_id       = azurerm_data_factory.adf.id
  url                   = "https://@{linkedService().storage_account_name}.dfs.core.windows.net"
  use_managed_identity  = true

  parameters = {
    storage_account_name = ""
  }
}

# Delimited Text (CSV) Dataset
resource "azurerm_data_factory_dataset_delimited_text" "csv_dataset" {
  name                = "DS_ADLS_CSV"
  data_factory_id     = azurerm_data_factory.adf.id
  linked_service_name   = azurerm_data_factory_linked_service_data_lake_storage_gen2.adls.name

  parameters = {
    container_name       = "landing"
    folder_path          = ""
    file_name            = ""
  }

  azure_blob_fs_location {
    file_system = "@dataset().container_name"
    path        = "@dataset().folder_path"
    filename    = "@dataset().file_name"
  }

  column_delimiter    = ","
  row_delimiter       = "\\n"
  first_row_as_header = true
  null_value          = ""
}

# Parquet Dataset
resource "azurerm_data_factory_dataset_parquet" "parquet_dataset" {
  name                = "DS_ADLS_Parquet"
  data_factory_id     = azurerm_data_factory.adf.id
  linked_service_name   = azurerm_data_factory_linked_service_data_lake_storage_gen2.adls.name

  parameters = {
    container_name       = ""
    folder_path          = ""
    file_name            = ""
  }

  azure_blob_fs_location {
    file_system = "@dataset().container_name"
    path        = "@dataset().folder_path"
    filename    = "@dataset().file_name"
  }
}

# Databricks Linked Service
resource "azurerm_data_factory_linked_service_azure_databricks" "databricks" {
  name                       = "LS_AzureDatabricks"
  data_factory_id            = azurerm_data_factory.adf.id
  adb_domain                 = "https://${var.databricks_workspace_url}"
  msi_work_space_resource_id = var.databricks_workspace_id
  
  new_cluster_config {
    node_type             = "Standard_DS3_v2"
    cluster_version       = "13.3.x-scala2.12"
    min_number_of_workers = 1
    max_number_of_workers = 2
    driver_node_type      = "Standard_DS3_v2"
  }
}
