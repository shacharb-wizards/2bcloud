# Variables
variable "resources_location" {
  type        = string
  default     = "westeurope"
  description = "Location of the resources."
}

variable "resource_name_prefix" {
  type        = string
  default     = "shacharb"
  description = "Prefix of resources in  Azure subscription."
}

variable "resource_group_name" {
  type        = string
  default     = "shacharb-CANDIDATE_RG"
  description = "resource group name in Azure subscription."
}

variable "subscription_id" {
  type        = string
  description = "The subscription_id to deploy the resources."
  default     = "2fa0e512-f70e-430f-9186-1b06543a848e"
}

variable "username" {
  type        = string
  description = "The username for the local account that will be created on the new VM."
  default     = "azureadmin"
}

# AKV
variable "kv_sku_name" {
  type        = string
  description = "The SKU of the vault to be created."
  default     = "standard"
  validation {
    condition     = contains(["standard", "premium"], var.kv_sku_name)
    error_message = "The sku_name must be one of the following: standard, premium."
  }
}

variable "key_permissions" {
  type        = list(string)
  description = "List of key permissions."
  default     = ["Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore", "Decrypt", "Encrypt", "UnwrapKey", "WrapKey", "Verify", "Sign", "Purge", "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"]
}

variable "certificate_permissions" {
  type        = list(string)
  description = "List of key permissions."
  default     = ["Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore", "ManageContacts", "ManageIssuers", "GetIssuers", "ListIssuers", "SetIssuers", "DeleteIssuers", "Purge"]
}

variable "secret_permissions" {
  type        = list(string)
  description = "List of secret permissions."
  default     = ["Set", "List", "Get", "Purge", "Recover", "Backup", "Restore", "Delete"]
}

variable "storage_permissions" {
  type        = list(string)
  description = "List of secret permissions."
  default     = ["Set", "List", "Get", "Purge", "Recover", "Backup", "Restore", "Delete"]
}

variable "msi_id" {
  type        = string
  description = "The Managed Service Identity ID. If this value isn't null (the default), 'data.azurerm_client_config.current.object_id' will be set to this value."
  default     = null
}
