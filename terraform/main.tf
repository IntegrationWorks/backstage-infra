data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

resource "azurerm_virtual_network" "this" {
  depends_on          = [data.azurerm_resource_group.this]
  name                = "${var.resource_prefix}-vnet"
  location            = data.azurerm_resource_group.this.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.0.0.0/16"]


}

resource "azurerm_subnet" "psql" {
  depends_on           = [azurerm_virtual_network.this]
  name                 = var.psql_subnet_name
  resource_group_name  = data.azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.0.0/24"]

  delegation {
    name = "delegation"

    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"

    }
  }
}

resource "azurerm_subnet" "aca-env" {
  depends_on           = [azurerm_virtual_network.this]
  name                 = var.aca_env_subnet_name
  resource_group_name  = data.azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.2.0/23"]
}
resource "azurerm_private_dns_zone" "this" {
  depends_on          = [data.azurerm_resource_group.this]
  name                = var.private_dns_zone_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_postgresql_flexible_server" "this" {
  name                = "${var.resource_prefix}-psql"
  location            = data.azurerm_resource_group.this.location
  resource_group_name = var.resource_group_name

  version                       = "16"
  delegated_subnet_id           = azurerm_subnet.psql.id
  private_dns_zone_id           = azurerm_private_dns_zone.this.id
  public_network_access_enabled = false
  administrator_login           = var.psql_username
  administrator_password        = var.psql_password

  storage_mb   = 32768
  storage_tier = "P4"
  sku_name     = "B_Standard_B1ms"
  depends_on   = [azurerm_private_dns_zone.this, azurerm_subnet.psql]
}





resource "azurerm_container_app_environment" "this" {
  depends_on                 = [azurerm_subnet.aca-env]
  name                       = "${var.resource_prefix}-aca-env"
  location                   = data.azurerm_resource_group.this.location
  resource_group_name        = data.azurerm_resource_group.this.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
  infrastructure_subnet_id   = azurerm_subnet.aca-env.id
}

resource "azurerm_log_analytics_workspace" "this" {
  depends_on          = [data.azurerm_resource_group.this]
  name                = "${var.resource_prefix}-logs"
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}
