variable "location" {
  description = "The Azure location where all resources in this example should be created"
}

variable "resource_group" {
  description = "The resource group"
}

variable "service_plan_name" {
  description = "The name of the service plan"
}

variable "service_name" {
  description = "The name of the service"
}

variable "mysql_server_name" {
  description = "The name of MySQL server"
}

variable "mysql_database_name" {
  description = "The name of the database"
}

variable "mysql_firewall_name" {
  description = "The name of the firewall"
}

variable "storage_name" {
  description = "The name of the storage account"
}
