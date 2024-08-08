# Backstage Base and Platform Infrastructure

This repository contains Terraform code for deploying networking, a Flexible PostgresSQL Database and Azure Container Apps (ACA) Environment. There  are other supporting resources defined as well. The resources in this repo are for the base and platform level. These have been separated from the application level code and infra, which is defined in the [backstage-app](https://github.com/IntegrationWorks/backstage-app) repository, to separate concerns as application level code is likely to be updated more frequently.

## Resources

### Resource Group

Using the Terraform data source `azurerm_resource_group`, we can access information about an existing Azure Resource Group.

This resource group will be used to group all the related Azure resources for the Backstage deployment (including application level resources).

### Virtual Network (VNet)

Using the Terraform resource `azurerm_virtual_network`, we can create an Azure Virtual Network.

This VNet will host our database and container apps. This will allow our resources to communicate securely and privately with each other as well as publicly with the internet.

### PostgreSQL Subnet

PostgreSQL Flexible Server requires a dedicated subnet. Using the terraform resource `azurerm_subnet`, we can provision a subnet within a VNet. The subnet `psql` is delegated to the `Microsoft.DBforPostgreSQL.flexibleServers` service. This allows the service to establish some basic network configuration rules for the subnet.

### ACA Environment Subnet

When using your own VNet with ACA you are required to create a dedicated subnet for your ACA environment. Although not specified in the resource definition, the ACA environment will delegate the provided subnet `aca-env` automatically to the ACA environment service.

### Private DNS Zone

Using the `azurerm_private_dns_zone` resource, a private DNS zone is provisioned.

A private DNS Zone provides a way to manage and resolve domain names in a  virtual network. Using a private DNS zone, you can use your own custom domain name. The records contained in a private DNS zone aren't resolvable from the internet.

### PostgresSQL Flexible Server

Backstage requires a Postgres database for persistence. In this instance, PostgreSQL Flexible Server is used. Using the `azuerm_postgresql_flexible_server` resource, this database can be provisioned.

This database has no public access, and is given a private dns zone which provides a hostname that is accessible internally by other resources. It also requires a delegated subnet which is injected.

Administrator username and password are stored in Github Secrets and injected through Github Actions.

### Container Apps Environment

An Azure Container Apps Environment can be provisioned using the `azurerm_container_app_environment` resource.

This resource provides a secure boundary around one or more container apps. The Container Apps runtime manages the environment by handling the OS, scaling, fail over and resource balancing.

### Log Analytics Workspace

An Azure Log Analytics Workspace can be provisioned using the `azurerm_log_analytics_workspace` resource.

This workspace is tied to the ACA environment. It stores console and system logs from container apps associated with the environment. This way logs can be saved and reviewed at a later date.

## Deployment Pipeline

There is a Github workflow defined in [deploy.yaml](./.github/workflows/deploy.yaml). This workflow manages the deployment of resources to Azure but also can destroy said resources.

The workflow first logs into Azure which is needed for Terraform to have permission to deploy resources.

Terraform is then setup on the runner. Then there are steps to initialise the terraform directory and validate the terraform files.

Then there are steps to perform `terraform plan` and `terraform apply` which will deploy the resources to Azure. If the destroy input is true, plan and apply do not run and instead `terraform destroy` is run which will remove the resources from Azure.
