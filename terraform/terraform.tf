# Terraform
terraform {

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.13.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "2.1.0"
    }
}
}