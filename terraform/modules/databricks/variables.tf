variable "workspace_name" {
  description = "Name of the Databricks workspace"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "managed_resource_group_name" {
  description = "Optional managed resource group name for the Databricks workspace. Set this when creating replacement workspaces to avoid collisions."
  type        = string
  default     = null
}

variable "sku" {
  description = "SKU of the Databricks workspace (standard, premium, or trial)"
  type        = string
  default     = "standard"
}

variable "no_public_ip" {
  description = "Whether to enable Secure Cluster Connectivity / No Public IP. Disable in cost-sensitive dev environments to avoid managed NAT Gateway charges."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
