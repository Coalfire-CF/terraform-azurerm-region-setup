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

variable "fw_virtual_network_subnet_ids" {
  type        = list(string)
  description = "List of subnet ids for the firewall"
  default     = []
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

variable "additional_resource_groups" {
  type        = list(string)
  description = "Additional resource groups to create"
  default     = []
}

# Optional custom name inputs
variable "compute_gallery_name" {
  type        = string
  description = "(Optional) Custom name for the Azure Compute Gallery (Shared Image Gallery)"
  default     = local.default_compute_gallery_name
}
variable "cloudshell_storageaccount_name" {
  type        = string
  description = "(Optional) Custom name for the Cloudshell Storage Account"
  default     = local.default_cloudshell_storageaccount_name
}
variable "ars_storageaccount_name" {
  type        = string
  description = "(Optional) Custom name for the ars Storage Account"
  default     = local.default_ars_storageaccount_name
}
variable "docs_storageaccount_name" {
  type        = string
  description = "(Optional) Custom name for the Documents Storage Account"
  default     = local.default_docs_storageaccount_name
}
variable "flowlogs_storageaccount_name" {
  type        = string
  description = "(Optional) Custom name for the Flow Logs Storage Account"
  default     = local.default_flowlogs_storageaccount_name
}
variable "installs_storageaccount_name" {
  type        = string
  description = "(Optional) Custom name for the Installs Storage Account"
  default     = local.default_installs_storageaccount_name
}
variable "vmdiag_storageaccount_name" {
  type        = string
  description = "(Optional) Custom name for the VM Diagnostic Logs Storage Account"
  default     = local.default_vmdiag_storageaccount_name
}
variable "network_watcher_name" {
  type        = string
  description = "(Optional) Custom name for the Azure Network Watcher"
  default     = local.default_network_watcher_name
}
