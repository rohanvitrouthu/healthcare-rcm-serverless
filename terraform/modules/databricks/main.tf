resource "azurerm_databricks_workspace" "this" {
  name                = var.workspace_name
  resource_group_name = var.resource_group_name
  location            = var.location
  managed_resource_group_name = var.managed_resource_group_name
  sku                 = var.sku

  custom_parameters {
    no_public_ip = var.no_public_ip
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}
