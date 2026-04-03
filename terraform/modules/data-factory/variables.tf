variable "data_factory_name" {
  description = "Name of the Azure Data Factory"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region location"
  type        = string
}

variable "tags" {
  description = "Tags for the data factory"
  type        = map(string)
  default     = {}
}

variable "key_vault_id" {
  description = "ID of the Azure Key Vault"
  type        = string
}

variable "databricks_workspace_url" {
  description = "URL of the Databricks Workspace"
  type        = string
}

variable "databricks_workspace_id" {
  description = "ARM Resource ID of the Databricks Workspace"
  type        = string
}
