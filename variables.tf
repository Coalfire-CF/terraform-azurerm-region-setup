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

variable "sa_subnet_ids" {
  type        = list(string)
  description = "Subnet IDs allowed through the firewall of every storage account (service endpoints). Applies only when public_network_access is Enabled."
  default     = []
  nullable    = false
}

variable "ip_for_remote_access" {
  description = "Public IPv4 addresses or CIDR ranges allowed through the firewall of every storage account. Applies only when public_network_access is Enabled. Each entry opens the account's public endpoint to that address."
  type        = list(string)
  default     = []
  nullable    = false
}

variable "core_kv_id" {
  type        = string
  description = "Resource ID of the Key Vault that holds or receives the customer-managed keys. Required when enable_customer_managed_key is true; unused otherwise."
  default     = null

  validation {
    condition     = !var.enable_customer_managed_key || var.core_kv_id != null
    error_message = "core_kv_id is required when enable_customer_managed_key is true."
  }
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
  default     = "default"
}
variable "cloudshell_storageaccount_name" {
  type        = string
  description = "(Optional) Custom name for the Cloudshell Storage Account"
  default     = "default"
  validation {
    condition     = length(var.cloudshell_storageaccount_name) < 25 && length(var.cloudshell_storageaccount_name) > 2
    error_message = "Storage account names must be between 3 and 24 characters in length"
  }
  validation {
    condition     = can(regex("^[0-9a-z]+$", var.cloudshell_storageaccount_name))
    error_message = "Storage account names must contain only lowercase letters and numbers"
  }
}
variable "ars_storageaccount_name" {
  type        = string
  description = "(Optional) Custom name for the ars Storage Account"
  default     = "default"
  validation {
    condition     = length(var.ars_storageaccount_name) < 25 && length(var.ars_storageaccount_name) > 2
    error_message = "Storage account names must be between 3 and 24 characters in length"
  }
  validation {
    condition     = can(regex("^[0-9a-z]+$", var.ars_storageaccount_name))
    error_message = "Storage account names must contain only lowercase letters and numbers"
  }
}
variable "docs_storageaccount_name" {
  type        = string
  description = "(Optional) Custom name for the Documents Storage Account"
  default     = "default"
  validation {
    condition     = length(var.docs_storageaccount_name) < 25 && length(var.docs_storageaccount_name) > 2
    error_message = "Storage account names must be between 3 and 24 characters in length"
  }
  validation {
    condition     = can(regex("^[0-9a-z]+$", var.docs_storageaccount_name))
    error_message = "Storage account names must contain only lowercase letters and numbers"
  }
}
variable "flowlogs_storageaccount_name" {
  type        = string
  description = "(Optional) Custom name for the Flow Logs Storage Account"
  default     = "default"
  validation {
    condition     = length(var.flowlogs_storageaccount_name) < 25 && length(var.flowlogs_storageaccount_name) > 2
    error_message = "Storage account names must be between 3 and 24 characters in length"
  }
  validation {
    condition     = can(regex("^[0-9a-z]+$", var.flowlogs_storageaccount_name))
    error_message = "Storage account names must contain only lowercase letters and numbers"
  }
}
variable "installs_storageaccount_name" {
  type        = string
  description = "(Optional) Custom name for the Installs Storage Account"
  default     = "default"
  validation {
    condition     = length(var.installs_storageaccount_name) < 25 && length(var.installs_storageaccount_name) > 2
    error_message = "Storage account names must be between 3 and 24 characters in length"
  }
  validation {
    condition     = can(regex("^[0-9a-z]+$", var.installs_storageaccount_name))
    error_message = "Storage account names must contain only lowercase letters and numbers"
  }
}
variable "vmdiag_storageaccount_name" {
  type        = string
  description = "(Optional) Custom name for the VM Diagnostic Logs Storage Account"
  default     = "default"
  validation {
    condition     = length(var.vmdiag_storageaccount_name) < 25 && length(var.vmdiag_storageaccount_name) > 2
    error_message = "Storage account names must be between 3 and 24 characters in length"
  }
  validation {
    condition     = can(regex("^[0-9a-z]+$", var.vmdiag_storageaccount_name))
    error_message = "Storage account names must contain only lowercase letters and numbers"
  }
}
variable "network_watcher_name" {
  type        = string
  description = "(Optional) Custom name for the Azure Network Watcher"
  default     = "default"
}

variable "file_upload_paths" {
  type        = list(string)
  description = "Paths of files to upload to the uploads container in the installs storage account. Uploads use the blob data plane: shared keys are off, so the caller's azurerm provider needs storage_use_azuread = true and an Entra role such as Storage Blob Data Contributor on the account, and the runner needs network access to the blob endpoint (a private endpoint when public_network_access is Disabled)."
  default     = []
}

variable "vm_image_definitions" {
  description = "Image definitions to create in the compute gallery. An entry with managed_image_id also gets an image version."
  type = list(object({
    name                 = string
    os_type              = string
    identifier_publisher = string
    identifier_offer     = string
    identifier_sku       = string
    hyper_v_generation   = string
    managed_image_id     = optional(string, null) # Optional: source for image version

    # Make purchase_plan attributes optional
    purchase_plan_name      = optional(string)
    purchase_plan_publisher = optional(string)
    purchase_plan_product   = optional(string)
  }))
  default = []
}

variable "image_gallery_description" {
  type        = string
  description = "Description of the Shared Image Gallery to be created"
  default     = "Images for FedRAMP Environment"
}

variable "image_version_name" {
  type        = string
  description = "The name of the image version to be created"
  default     = "1.0.0"
}

variable "architecture" {
  type        = string
  description = "CPU architecture supported by an OS. Possbile values x64 and Arm64"
  default     = "x64"
}

variable "enable_customer_managed_key" {
  type        = bool
  description = "Encrypt all six storage accounts with customer-managed keys in core_kv_id. When false, platform-managed keys plus infrastructure encryption apply. When true and a *_cmk_key_name is null, the storage module creates a key named <account>-cmk, so the deploying identity needs key create rights on the vault."
  default     = false
}

variable "network_watcher_enabled" {
  type        = bool
  description = "Enable Network Watcher in the region"
  default     = true
}

variable "regional_replica_count" {
  type        = number
  description = "The number of replicas of the Shared Image Gallery to be created in the target region. Must be between 1 and 5."
  default     = 1
}

variable "storage_account_type" {
  type        = string
  description = "Replica storage type for gallery image versions: Standard_LRS, Standard_ZRS or Premium_LRS. Default Standard_LRS: replicas can be rebuilt from the source managed image. Use Standard_ZRS where the region has availability zones and replica loss would block deployments."
  default     = "Standard_LRS"
}

## Key Vault CMK Key Names (optional overrides) ##
variable "ars_cmk_key_name" {
  type        = string
  description = "(Optional) Name of the Key Vault Key to use for Customer Managed Keys in the ARS Storage Account"
  default     = null
}

variable "docs_cmk_key_name" {
  type        = string
  description = "(Optional) Name of the Key Vault Key to use for Customer Managed Keys in the Documents Storage Account"
  default     = null
}

variable "flowlogs_cmk_key_name" {
  type        = string
  description = "(Optional) Name of the Key Vault Key to use for Customer Managed Keys in the Flow Logs Storage Account"
  default     = null
}

variable "installs_cmk_key_name" {
  type        = string
  description = "(Optional) Name of the Key Vault Key to use for Customer Managed Keys in the Installs Storage Account"
  default     = null
}

variable "vmdiag_cmk_key_name" {
  type        = string
  description = "(Optional) Name of the Key Vault Key to use for Customer Managed Keys in the VM Diagnostic Logs Storage Account"
  default     = null
}

variable "cloudshell_cmk_key_name" {
  type        = string
  description = "(Optional) Name of an existing Key Vault key in core_kv_id for the Cloud Shell account's customer-managed key. Null creates one when enable_customer_managed_key is true."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags merged onto every taggable resource, after global_tags and regional_tags."
  default     = {}
  nullable    = false
}

variable "public_network_access" {
  type        = string
  description = "Public network access for all six storage accounts: Disabled or Enabled. Enabled exposes the account endpoints to the internet, limited only by ip_for_remote_access and sa_subnet_ids. Keep Disabled and use private_endpoint_subnet_id."
  default     = "Disabled"

  validation {
    condition     = contains(["Disabled", "Enabled"], var.public_network_access)
    error_message = "public_network_access must be Disabled or Enabled."
  }
}

variable "storage_replication_type" {
  type        = string
  description = "Replication for all six storage accounts: LRS, GRS, RAGRS, ZRS, GZRS or RAGZRS. Default GRS matches the storage-account module and keeps a copy in the paired region. Use ZRS or GZRS where the region has availability zones. LRS keeps one copy in one datacenter."
  default     = "GRS"

  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.storage_replication_type)
    error_message = "storage_replication_type must be one of LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS."
  }
}

variable "private_endpoint_subnet_id" {
  type        = string
  description = "Subnet ID for a private endpoint on each of the six storage accounts. Null creates no private endpoints; with public_network_access Disabled the accounts are then reachable only by trusted Azure services."
  default     = null
}

variable "blob_private_dns_zone_id" {
  type        = string
  description = "ID of the privatelink.blob private DNS zone linked to the blob private endpoints of the ars, docs, flowlogs, installs and vm_diag accounts. Null skips the DNS zone group."
  default     = null
}

variable "file_private_dns_zone_id" {
  type        = string
  description = "ID of the privatelink.file private DNS zone linked to the Cloud Shell account's file private endpoint. Null skips the DNS zone group."
  default     = null
}

variable "cloudshell_shared_access_key_enabled" {
  type        = bool
  description = "Allow Shared Key authorization on the Cloud Shell storage account. Cloud Shell is expected to mount its file share with the account key, so Cloud Shell likely cannot use this account while false. True lets anyone holding a key bypass Entra ID and RBAC on this account."
  default     = false
}

variable "blob_delete_retention_days" {
  type        = number
  description = "Days deleted blobs are kept on all six storage accounts. Point-in-time restore keeps 6 days, so this must be at least 7. Lower values shorten the recovery window."
  default     = 7
  nullable    = false

  validation {
    condition     = var.blob_delete_retention_days >= 7 && var.blob_delete_retention_days <= 365
    error_message = "blob_delete_retention_days must be between 7 and 365."
  }
}

variable "container_delete_retention_days" {
  type        = number
  description = "Days deleted containers are kept on all six storage accounts. Lower values shorten the recovery window."
  default     = 7
  nullable    = false

  validation {
    condition     = var.container_delete_retention_days >= 1 && var.container_delete_retention_days <= 365
    error_message = "container_delete_retention_days must be between 1 and 365."
  }
}

variable "share_delete_retention_days" {
  type        = number
  description = "Days deleted file shares are kept on all six storage accounts, including the Cloud Shell share. Lower values shorten the recovery window."
  default     = 7
  nullable    = false

  validation {
    condition     = var.share_delete_retention_days >= 1 && var.share_delete_retention_days <= 365
    error_message = "share_delete_retention_days must be between 1 and 365."
  }
}
