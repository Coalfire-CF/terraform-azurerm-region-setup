variable "global_tags" {
  type        = map(string)
  description = "Global level tags"
}

variable "regional_tags" {
  type        = map(string)
  description = "Regional level tags"
}

variable "location" {
  description = "The Azure location/region to create resources in"
  type        = string
}

variable "location_abbreviation" {
  description = "The  Azure location/region in 4 letter code"
  type        = string
}

variable "app_abbreviation" {
  description = "The prefix for the blob storage account names"
  type        = string
}

variable "subscription_id" {
  description = "The Azure subscription ID where resources are being deployed into"
  type        = string
}

variable "tenant_id" {
  description = "The Azure tenant ID that owns the deployed resources"
  type        = string
}

# variable "sub_diag_logs" {
#   description = "Types of logs to gather for subscription diagnostics"
#   type        = list(any)
# }

variable "mgmt_rg_name" {
  description = "Management plane resource group name"
  type        = string
  default     = "management-rg-1"
}

variable "app_rg_name" {
  description = "Application plane resource group name"
  type        = string
  default     = "application-rg-1"
}

variable "key_vault_rg_name" {
  description = "Key Vault resource group name"
  type        = string
  default     = "keyvault-rg-01"
}

variable "networking_rg_name" {
  description = "Networking resource group name"
  type        = string
  default     = "networking-rg-01"
}

variable "sas_start_date" {
  description = "value"
  type        = string
}

variable "sas_end_date" {
  description = "value"
  type        = string
}

# variable "create_monitor" {
#   description = "Whether or not to create Azure Monitor resources"
#   type        = bool
# }

variable "firewall_vnet_subnet_ids" {
  description = "Subnet ID's that should be allowed for the firewall"
  type        = string
  #default     = null
  default = [] #testing 
}

variable "ip_for_remote_access" {
  description = "This is the same as 'cidrs_for_remote_access' but without the /32 on each of the files. The 'ip_rules' in the storage account will not accept a '/32' address and I gave up trying to strip and convert the values over"
  type        = list(any)
}

variable "core_kv_id" {
  type = string
}

variable "diag_log_analytics_id" {
  description = "ID of the Log Analytics Workspace diagnostic logs should be sent to"
  type        = string
}

variable "resource_prefix" {
  type        = string
  description = "Name prefix used for resources"
}

variable "admin_principal_ids" {
  type        = set(string)
  description = "List of principal ID's for all admins"
}

variable "additional_resource_groups" {
  type        = list(string)
  description = "Additional resource groups to create"
  default     = []
}
