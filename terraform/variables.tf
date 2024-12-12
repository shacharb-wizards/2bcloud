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