resource "azurerm_mssql_server" "server" {
  name                         = var.server_name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.admin_username
  administrator_login_password = var.admin_password

  tags = var.tags
}

resource "azurerm_mssql_database" "db" {
  name           = var.database_name
  server_id      = azurerm_mssql_server.server.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 2
  sku_name       = "Basic"  # Keeping costs low/zero for dev

  tags = var.tags
}

# Allow Azure Services to access the server
resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# Allow All IPs (For Dev/Demo ease of access from local machine - RESTRICT IN PROD)
# Ideally we would use the user's IP, but "Allow All" is often used in zero-config prototypes.
# I will comment this out and rely on specific rules if needed, but for now Azure Services covers Databricks/AKS.
# If the user needs local access, they can add their IP in the portal or we can add a var.
resource "azurerm_mssql_firewall_rule" "allow_all" {
  count            = var.allow_all_ips ? 1 : 0
  name             = "AllowAll"
  server_id        = azurerm_mssql_server.server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}
