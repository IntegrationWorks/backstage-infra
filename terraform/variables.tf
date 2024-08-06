variable "resource_group_name" {
  description = "Name of the resource group"
}

variable "resource_prefix" {
  description = "Resource naming prefix"

}

variable "psql_username" {
  description = "Postgres DB admin username"
}

variable "psql_password" {
  description = "Postgres DB admin password"
}

variable "private_dns_zone_name" {
  description = "Private domain name for postgres database."
}

variable "psql_subnet_name" {
  description = "name of the postgres db subnet"
}

variable "aca_env_subnet_name" {
  description = "Name of the container apps environment "
}
