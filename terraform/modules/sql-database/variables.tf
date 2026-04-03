variable "server_name" {
  description = "Name of the SQL Server"
  type        = string
}

variable "database_name" {
  description = "Name of the SQL Database"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "admin_username" {
  description = "Administrator username"
  type        = string
  default     = "sqladmin"
}

variable "admin_password" {
  description = "Administrator password"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "allow_all_ips" {
  description = "Allow all IP addresses to access the server (Dev only)"
  type        = bool
  default     = false
}
