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
    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.16.1"
    }
  }
}