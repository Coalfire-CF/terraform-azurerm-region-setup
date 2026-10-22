![Coalfire](coalfire_logo.png)

# terraform-azurerm-region-setup

## Description

This module creates basic Azure resources that are foundational to environment set up in a specific Azure region. It is the second step in deploying the [Coalfire-Azure-RAMPpak](https://github.com/Coalfire-CF/Coalfire-Azure-RAMPpak) FedRAMP Framework.

Learn more at [Coalfire OpenSource](https://coalfire.com/opensource).

### Dependencies

- A Log Analytics workspace for storage diagnostics (`diag_log_analytics_id`).
- A Key Vault (`core_kv_id`) only when `enable_customer_managed_key = true`. The [Coalfire-CF/terraform-azurerm-security-core](https://github.com/Coalfire-CF/terraform-azurerm-security-core) module provides one.

### Resource List

- Resource groups: network, application, management, key vault, plus any in `additional_resource_groups`
- Network Watcher (optional, `network_watcher_enabled`)
- Azure Compute Gallery, with optional image definitions and versions
- Storage accounts, each through [terraform-azurerm-storage-account](https://github.com/Coalfire-CF/terraform-azurerm-storage-account) v3.0.0 with diagnostics to Log Analytics:
  - Azure Recovery Services (ARS)
  - documents
  - flow logs
  - installers, with optional file uploads
  - VM diagnostics
  - Cloud Shell

The module has no backend and reads no remote state. The caller owns both.

## Usage

```hcl
provider "azurerm" {
  features {}
  environment                     = "usgovernment"
  resource_provider_registrations = "none"
  resource_providers_to_register  = ["Microsoft.Compute", "Microsoft.Insights", "Microsoft.Network", "Microsoft.Storage"]
  storage_use_azuread             = true
}

module "setup" {
  source = "git::https://github.com/Coalfire-CF/terraform-azurerm-region-setup?ref=v3.0.0"

  location_abbreviation = var.location_abbreviation
  location              = var.location
  resource_prefix       = var.resource_prefix
  app_abbreviation      = var.app_abbreviation
  regional_tags         = var.regional_tags
  global_tags           = var.global_tags
  tags                  = var.tags
  mgmt_rg_name          = "${var.resource_prefix}-management-rg"
  app_rg_name           = "${var.resource_prefix}-application-rg"
  key_vault_rg_name     = "${var.resource_prefix}-keyvault-rg"
  networking_rg_name    = "${var.resource_prefix}-networking-rg"
  diag_log_analytics_id = var.diag_log_analytics_id

  private_endpoint_subnet_id = var.private_endpoint_subnet_id
  blob_private_dns_zone_id   = var.blob_private_dns_zone_id
  file_private_dns_zone_id   = var.file_private_dns_zone_id

  additional_resource_groups = [
    "${var.resource_prefix}-identity-rg"
  ]
}
```

A complete root is in [`examples/default`](examples/default).

## Security defaults

All six storage accounts get these defaults from the storage-account module. The input that loosens each one is named.

| Default | Loosened by |
| --- | --- |
| Public network access `Disabled` | `public_network_access = "Enabled"` |
| Firewall default action `Deny`, trusted Azure services bypass | `ip_for_remote_access`, `sa_subnet_ids` (apply only when public access is Enabled) |
| Shared Key authorization off | `cloudshell_shared_access_key_enabled` (Cloud Shell account only) |
| Minimum TLS 1.2, HTTPS only | not configurable |
| Platform-managed keys plus infrastructure encryption | `enable_customer_managed_key` switches to customer-managed keys |
| Soft delete for blobs, containers and shares (7 days), point-in-time restore (6 days) | `blob_delete_retention_days`, `container_delete_retention_days`, `share_delete_retention_days` |
| GRS replication | `storage_replication_type` |

## Private endpoints

Set `private_endpoint_subnet_id` to create a private endpoint on each storage account:

- `blob_private_dns_zone_id`: the `privatelink.blob` zone for the ARS, docs, flow logs, installs and VM diagnostics accounts.
- `file_private_dns_zone_id`: the `privatelink.file` zone for the Cloud Shell account. Its endpoint targets the `file` subresource.

With `private_endpoint_subnet_id = null` the module creates no endpoints. With public access Disabled, only trusted Azure services can then reach the accounts.

## Customer-managed keys

Off by default. Setting `enable_customer_managed_key = true` needs `core_kv_id`. For each account, either set its `*_cmk_key_name` to an existing key, or leave it null and give the deploying identity key create rights on the vault so the storage module can create one. To reuse a security-core key named `cloudshell-cmk`, set `cloudshell_cmk_key_name = "cloudshell-cmk"`.

## Cloud Shell

Cloud Shell is expected to mount its file share with the storage account key. Shared Key authorization is off by default, so Cloud Shell likely cannot use this account until you set `cloudshell_shared_access_key_enabled = true`. That lets anyone holding an account key bypass Entra ID and RBAC on this account. Leave it off if you do not use Cloud Shell with this account.

## Optional arguments

This module accepts a number of additional arguments to modify resource deployments.

### Custom resource names

You may optionally supply custom names for all resources created by this module, to support various naming convention requirements:

```hcl
module "setup" {
...
  compute_gallery_name           = "computegallery01"
  cloudshell_storageaccount_name = "usgovcloudshellsa"
  ars_storageaccount_name        = "usgovarssa"
  docs_storageaccount_name       = "usgovdocssa"
  flowlogs_storageaccount_name   = "usgovflowlogssa"
  installs_storageaccount_name   = "usgovinstallssa"
  vmdiag_storageaccount_name     = "usgovdiagsa"
  network_watcher_name           = "usgovnetworkwatcher"
...
}

```

### File uploads

Installation shellscripts and other files may be uploaded to blob storage by specifying their paths.

The `file_upload_paths` argument accepts a list of any number of paths. The file at each path will be uploaded to the `uploads` container in the installs storage account. In the example below, two scripts are uploaded:

```hcl
module "setup" {
...
 file_upload_paths = [
    "../../../../shellscripts/linux/linux_join_ad.sh",
    "../../../../shellscripts/linux/linux_monitor_agent.sh"
  ]
...
}
```

Uploads use the blob data plane, and Shared Key is off. They need:

- `storage_use_azuread = true` in the caller's azurerm provider block.
- An Entra role such as `Storage Blob Data Contributor` on the installs account for the identity running Terraform.
- Network reach from the runner to the blob endpoint. With public access Disabled, that means a private endpoint the runner can resolve and reach.

Terraform will dynamically set the blob name (filename) to the filename of the script provided, e.g. `../shellscripts/linux/arbitrary_script_name.sh` will be appear in Azure as `arbitrary_script_name.sh`

If `file_upload_paths` is defined, `file_uploads` outputs a key-value map of all uploads, where the key is the script name (minus file extension) and the value is the blob URL:

```hcl
# Example Output
file_uploads = {
  "linux_join_ad" = "https://storageaccountname.blob.core.usgovcloudapi.net/uploads/linux_join_ad.sh"
  "linux_monitor_agent" = "https://storageaccountname.blob.core.usgovcloudapi.net/uploads/linux_monitor_agent.sh"
}
```

### Azure Compute Gallery (Image Gallery) Image Definitions

Any number of VM image definitions may be bootstapped in the Azure Compute Gallery by specifying `vm_image_definitions` as shown in the example below:

```hcl
  module "setup" {
  ...
  vm_image_definitions = [
    {
      name                 = "rhel-8-10-golden-stig"
      os_type              = "Linux"
      identifier_publisher = "rhel"
      identifier_offer     = "LinuxServer"
      identifier_sku       = "RHEL8-10"
      hyper_v_generation   = "V2"
    },
    {
      name                 = "win-server2022-golden"
      os_type              = "Windows"
      identifier_publisher = "microsoft"
      identifier_offer     = "WindowsServer"
      identifier_sku       = "2022-datacenter-g2"
      hyper_v_generation   = "V2"
    }
  ]
}
```

If `vm_image_definitions` is defined, the module will output a key-value map of all VM image definitions, where the key is the image name and the value is the image ID:

```hcl
# Example Output
vm_image_definitions = {
  "rhel-8-10-golden-stig" = "/subscriptions/<subscription_id>/resourceGroups/<resource_group_name>/providers/Microsoft.Compute/galleries/<gallery_name>/images/rhel-8-10-golden-stig"
  "win-server2022-golden" = "/subscriptions/<subscription_id>/resourceGroups/<resource_group_name>/providers/Microsoft.Compute/galleries/<gallery_name>/images/win-server2022-golden"
}
```

## Breaking changes in 3.0.0

- Requires Terraform `>= 1.16.6` and azurerm `~> 5.10`.
- Storage accounts use terraform-azurerm-storage-account v3.0.0. Public network access defaults to `Disabled` and Shared Key is off on all six accounts.
- `public_network_access_enabled` (bool) is replaced by `public_network_access` (`Disabled` or `Enabled`).
- `sas_start_date`, `sas_end_date` and the `storage_account_vm_diag_sas` output are removed. Use managed identity and RBAC on `vmdiag_endpoint`.
- `enable_customer_managed_key` defaults to `false`. `core_kv_id` is optional and required only with CMK.
- `ip_for_remote_access` is now `list(string)` with default `[]`.
- The Cloud Shell account is created by the storage module (`module.cloudshell_sa`). It is GRS, has soft delete and point-in-time restore, and no longer reads a `cloudshell-cmk` key or assigns a role on `core_kv_id`.
- New inputs: `tags`, `storage_replication_type`, `private_endpoint_subnet_id`, `blob_private_dns_zone_id`, `file_private_dns_zone_id`, `cloudshell_shared_access_key_enabled`, `cloudshell_cmk_key_name`, `blob_delete_retention_days`, `container_delete_retention_days`, `share_delete_retention_days`.
- Resource groups and gallery image definitions now carry tags.
