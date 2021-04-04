terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "random" {}

resource "azurerm_resource_group" "todo-rg" {
  name     = var.resource_group
  location = var.location
}

resource "azurerm_app_service_plan" "todo-asp" {
  name                = var.service_plan_name
  location            = azurerm_resource_group.todo-rg.location
  resource_group_name = azurerm_resource_group.todo-rg.name

  sku {
    tier = "Basic"
    size = "B1"
  }
}

resource "azurerm_app_service" "todo-as" {
  name                = var.service_name
  location            = azurerm_resource_group.todo-rg.location
  resource_group_name = azurerm_resource_group.todo-rg.name
  app_service_plan_id = azurerm_app_service_plan.todo-asp.id

  site_config {
    java_version = "11"
  }
}

resource "random_password" "todo-pwd" {
  length           = 16
  special          = true
}

resource "azurerm_mysql_server" "todo-db" {
  name                = var.mysql_server_name
  location            = azurerm_resource_group.todo-rg.location
  resource_group_name = azurerm_resource_group.todo-rg.name

  administrator_login          = "lingounet"
  administrator_login_password = random_password.todo-pwd.result

  sku_name            = "B_Gen5_1"
  version             = "5.7"

  storage_mb = "5120"
  auto_grow_enabled = true

  backup_retention_days = 7
  geo_redundant_backup_enabled = false

  public_network_access_enabled = true
  ssl_enforcement_enabled = true
  ssl_minimal_tls_version_enforced = "TLS1_2"
}

# This is the database that our application will use
resource "azurerm_mysql_database" "main" {
  name                = var.mysql_database_name
  resource_group_name = azurerm_resource_group.todo-rg.name
  server_name         = azurerm_mysql_server.todo-db.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

# This rule is to enable the 'Allow access to Azure services' checkbox
resource "azurerm_mysql_firewall_rule" "main" {
  name                = var.mysql_firewall_name
  resource_group_name = azurerm_resource_group.todo-rg.name
  server_name         = azurerm_mysql_server.todo-db.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

resource "azurerm_storage_account" "todo-sa" {
  name                      = var.storage_name
  resource_group_name       = azurerm_resource_group.todo-rg.name
  location                  = azurerm_resource_group.todo-rg.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  account_kind              = "StorageV2"
  enable_https_traffic_only = "true"
  min_tls_version           = "TLS1_2"
  static_website {
    index_document = "index.html"
  }
}
