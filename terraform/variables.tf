
variable "resourceGroupName" {
    description = "Name of Resource Group holding PostgreSQL Server."
    default = "PostgreSQLTest"
}

variable "location" {
  description = "Azure Region for deployment"
  default = "eastus"
}

variable "serverName" {
  description = "Database server name"
  default = "postgresqlserver"
}