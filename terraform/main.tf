resource "random_integer" "deployment" {
  min = 10000
  max = 99999
}

resource "azurerm_resource_group" "rg" {
  name     = var.resourceGroupName
  location = var.location
}

resource "azurerm_postgresql_server" "postgresqlServer" {
  name                = "${var.serverName}-${random_integer.deployment.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  administrator_login          = "psqladminun"
  administrator_login_password = "H@Sh1CoR3!"

  sku_name   = "GP_Gen5_4"
  version    = "11"
  storage_mb = 640000

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = false

  public_network_access_enabled    = false
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"
}

resource "azurerm_postgresql_firewall_rule" "postgreSQLServerFirewallRules" {
  name                = "ClientIP"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_server.postgresqlServer.name
  start_ip_address    = "40.112.0.0"
  end_ip_address      = "40.112.255.255"
}

resource "azurerm_postgresql_database" "postgresqlDatabase" {
  count               = 200
  name                = "database-${count.index}"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_server.postgresqlServer.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}
