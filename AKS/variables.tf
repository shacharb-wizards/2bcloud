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
  description = "The username for the local account that will be created on the new cluster."
  default     = "azureadmin"
}


variable "node_count" {
  type        = number
  description = "The initial quantity of nodes for the node pool."
  default     = 1
}

variable "node_type" {
  type        = string
  description = "The initial nodes type for the node pool."
  #default     = "standard_b2s"
  #default = "standard_d2as_v6"
  default = "standard_d2s_v3"
}

variable "msi_id" {
  type        = string
  description = "The Managed Service Identity ID. If this value isn't null (the default), 'data.azurerm_client_config.current.object_id' will be set to this value."
  default     = null
}

variable "appId" {
  description = "Azure Kubernetes Service Cluster service principal"
}

variable "password" {
  description = "Azure Kubernetes Service Cluster password"
}

variable "dns_zone_name" {
  type        = string
  default     = "shacharb.local"
  description = "Name of the DNS zone."
}

variable "dns_ttl" {
  type        = number
  default     = 3600
  description = "Time To Live (TTL) of the DNS record (in seconds)."
}
