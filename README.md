![Coalfire](coalfire_logo.png)

# terraform-azurerm-region-setup

## Description

This module creates basic Azure resources that are foundational to environment set up in a specific Azure region. It is the second step in deploying the [Coalfire-Azure-RAMPpak](https://github.com/Coalfire-CF/Coalfire-Azure-RAMPpak) FedRAMP Framework. 

Learn more at [Coalfire OpenSource](https://coalfire.com/opensource).

### Dependencies

- This module is dependent on the [Coalfire-CF/terraform-azurerm-security-core](https://github.com/Coalfire-CF/terraform-azurerm-security-core) module being deployed. 

### Resource List

- Resource Groups
- Azure Monitor
- Network Watcher
- Azure Image Gallery
- Storage Account Blob and Container for terraform remote state lock
- Storage Account Blobs for
  - backup
  - flowlogs
  - monitor logs
  - installer files
  - CloudShell
  - Terraform remote state

## Code Updates

`tstate.tf` Update to the appropriate version and storage accounts, see sample below:

``` hcl
terraform {
  required_version = ">= 1.1.7"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.45.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "prod-mp-core-rg"
    storage_account_name = "prodmpsatfstate"
    container_name       = "tfstatecontainer"
    environment          = "usgovernment"
    key                  = "setup.tfstate"
  }
}
```

Update the `remote-data.tf` file to add the setup security state key. Example remote data block: 

``` hcl
data "terraform_remote_state" "usgv-region-setup" {
  backend = "azurerm"
  config = {
    resource_group_name  = "prod-mp-core-rg"
    storage_account_name = "prodmpsatfstate"
    container_name       = "tfstatecontainer"
    environment          = "usgovernment"
    key                  = "setup.tfstate"
  }
}
```

## Deployment Steps

This module can be called as outlined below.

- Change directory to the `/coalfire-azure-pak/terraform/prod/us-va/region-setup` folder.
- Run `terraform init` to download modules and create initial local state file.
- Run `terraform plan` to ensure no errors and validate plan is deploying expected resources.
- If everything looks correct in the plan output, run `terraform apply`.

## Usage

Include example for how to call the module below with generic variables

```hcl
provider "azurerm" {
  features {}
}

module "setup" {
  source = "github.com/Coalfire-CF/terraform-azurerm-region-setup"

  location_abbreviation = var.location_abbreviation
  location              = var.location
  resource_prefix       = local.resource_prefix
  app_abbreviation      = var.app_abbreviation
  regional_tags         = var.regional_tags
  global_tags           = merge(var.global_tags, local.global_local_tags)
  mgmt_rg_name          = "${local.resource_prefix}-management-rg"
  app_rg_name           = "${local.resource_prefix}-application-rg"
  key_vault_rg_name     = "${local.resource_prefix}-keyvault-rg"
  networking_rg_name    = "${local.resource_prefix}-networking-rg"
  sas_start_date        = "2023-10-06" #Change to today's date
  sas_end_date          = "2023-11-06" #Change to one month from now
  ip_for_remote_access  = var.ip_for_remote_access
  core_kv_id            = data.terraform_remote_state.core.outputs.core_kv_id
  diag_log_analytics_id = data.terraform_remote_state.core.outputs.core_la_id
  
  additional_resource_groups = [
    "${local.resource_prefix}-identity-rg"
  ]
}

```
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

Terraform will dynamically set the blob name (filename) to the filename of the script provided, e.g. `../shellscripts/linux/arbitrary_script_name.sh` will be appear in Azure as `arbitrary_script_name.sh`

If `file_upload_paths` is defined, `file_upload_urls` outputs a key-value map of all uploads, where the key is the script name (minus file extension) and the value is the blob URL: 
```hcl
# Example Output
file_upload_urls = {
  "linux_join_ad" = "https://storageaccountname.blob.core.usgovcloudapi.net/shellscripts/linux_join_ad.sh"
  "linux_monitor_agent" = "https://storageaccountname.blob.core.usgovcloudapi.net/shellscripts/linux_monitor_agent.sh"
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

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ars_sa"></a> [ars\_sa](#module\_ars\_sa) | git::https://github.com/Coalfire-CF/terraform-azurerm-storage-account | v1.0.1 |
| <a name="module_diag_cloudshell_sa"></a> [diag\_cloudshell\_sa](#module\_diag\_cloudshell\_sa) | git::https://github.com/Coalfire-CF/terraform-azurerm-diagnostics | v1.0.0 |
| <a name="module_docs_sa"></a> [docs\_sa](#module\_docs\_sa) | git::https://github.com/Coalfire-CF/terraform-azurerm-storage-account | v1.0.1 |
| <a name="module_flowlogs_sa"></a> [flowlogs\_sa](#module\_flowlogs\_sa) | git::https://github.com/Coalfire-CF/terraform-azurerm-storage-account | v1.0.1 |
| <a name="module_installs_sa"></a> [installs\_sa](#module\_installs\_sa) | git::https://github.com/Coalfire-CF/terraform-azurerm-storage-account | v1.0.5 |
| <a name="module_vm_diag"></a> [vm\_diag](#module\_vm\_diag) | git::https://github.com/Coalfire-CF/terraform-azurerm-storage-account | v1.0.1 |

## Resources

| Name | Type |
|------|------|
| [azurerm_network_watcher.fr_network_watcher](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_watcher) | resource |
| [azurerm_resource_group.additional_resource_groups](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_resource_group.application](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_resource_group.key_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_resource_group.management](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_resource_group.network](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.tstate_kv_crypto_user_cloudshell](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_shared_image.images](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/shared_image) | resource |
| [azurerm_shared_image_gallery.marketplaceimages](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/shared_image_gallery) | resource |
| [azurerm_shared_image_version.versions](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/shared_image_version) | resource |
| [azurerm_storage_account.cloudShell](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_account_customer_managed_key.enable_cloudShell_cmk](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_customer_managed_key) | resource |
| [azurerm_storage_blob.file_upload](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_blob) | resource |
| [azurerm_storage_account_sas.vm_diag_sas](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/storage_account_sas) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_resource_groups"></a> [additional\_resource\_groups](#input\_additional\_resource\_groups) | Additional resource groups to create | `list(string)` | `[]` | no |
| <a name="input_app_abbreviation"></a> [app\_abbreviation](#input\_app\_abbreviation) | The prefix for the blob storage account names | `string` | n/a | yes |
| <a name="input_app_rg_name"></a> [app\_rg\_name](#input\_app\_rg\_name) | Application plane resource group name | `string` | `"application-rg-1"` | no |
| <a name="input_architecture"></a> [architecture](#input\_architecture) | CPU architecture supported by an OS. Possbile values x64 and Arm64 | `string` | `"x64"` | no |
| <a name="input_ars_storageaccount_name"></a> [ars\_storageaccount\_name](#input\_ars\_storageaccount\_name) | (Optional) Custom name for the ars Storage Account | `string` | `"default"` | no |
| <a name="input_cloudshell_storageaccount_name"></a> [cloudshell\_storageaccount\_name](#input\_cloudshell\_storageaccount\_name) | (Optional) Custom name for the Cloudshell Storage Account | `string` | `"default"` | no |
| <a name="input_compute_gallery_name"></a> [compute\_gallery\_name](#input\_compute\_gallery\_name) | (Optional) Custom name for the Azure Compute Gallery (Shared Image Gallery) | `string` | `"default"` | no |
| <a name="input_core_kv_id"></a> [core\_kv\_id](#input\_core\_kv\_id) | n/a | `string` | n/a | yes |
| <a name="input_diag_log_analytics_id"></a> [diag\_log\_analytics\_id](#input\_diag\_log\_analytics\_id) | ID of the Log Analytics Workspace diagnostic logs should be sent to | `string` | n/a | yes |
| <a name="input_docs_storageaccount_name"></a> [docs\_storageaccount\_name](#input\_docs\_storageaccount\_name) | (Optional) Custom name for the Documents Storage Account | `string` | `"default"` | no |
| <a name="input_enable_sa_public_access"></a> [enable\_sa\_public\_access](#input\_enable\_sa\_public\_access) | n/a | `bool` | `true` | no |
| <a name="input_file_upload_paths"></a> [file\_upload\_paths](#input\_file\_upload\_paths) | A list of paths to files which will be uploaded to the installs storage account | `list(string)` | `[]` | no |
| <a name="input_flowlogs_storageaccount_name"></a> [flowlogs\_storageaccount\_name](#input\_flowlogs\_storageaccount\_name) | (Optional) Custom name for the Flow Logs Storage Account | `string` | `"default"` | no |
| <a name="input_fw_virtual_network_subnet_ids"></a> [fw\_virtual\_network\_subnet\_ids](#input\_fw\_virtual\_network\_subnet\_ids) | List of subnet ids for the firewall | `list(string)` | `[]` | no |
| <a name="input_global_tags"></a> [global\_tags](#input\_global\_tags) | Global level tags | `map(string)` | n/a | yes |
| <a name="input_image_gallery_description"></a> [image\_gallery\_description](#input\_image\_gallery\_description) | Description of the Shared Image Gallery to be created] | `string` | `"Images for FedRAMP Environment"` | no |
| <a name="input_image_version_name"></a> [image\_version\_name](#input\_image\_version\_name) | The name of the image version to be created | `string` | `"1.0.0"` | no |
| <a name="input_installs_storageaccount_name"></a> [installs\_storageaccount\_name](#input\_installs\_storageaccount\_name) | (Optional) Custom name for the Installs Storage Account | `string` | `"default"` | no |
| <a name="input_ip_for_remote_access"></a> [ip\_for\_remote\_access](#input\_ip\_for\_remote\_access) | This is the same as 'cidrs\_for\_remote\_access' but without the /32 on each of the files. The 'ip\_rules' in the storage account will not accept a '/32' address and I gave up trying to strip and convert the values over | `list(any)` | n/a | yes |
| <a name="input_key_vault_rg_name"></a> [key\_vault\_rg\_name](#input\_key\_vault\_rg\_name) | Key Vault resource group name | `string` | `"keyvault-rg-01"` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure location/region to create resources in | `string` | n/a | yes |
| <a name="input_location_abbreviation"></a> [location\_abbreviation](#input\_location\_abbreviation) | The  Azure location/region in 4 letter code | `string` | n/a | yes |
| <a name="input_mgmt_rg_name"></a> [mgmt\_rg\_name](#input\_mgmt\_rg\_name) | Management plane resource group name | `string` | `"management-rg-1"` | no |
| <a name="input_network_watcher_enabled"></a> [network\_watcher\_enabled](#input\_network\_watcher\_enabled) | Enable Network Watcher in the region | `bool` | `true` | no |
| <a name="input_network_watcher_name"></a> [network\_watcher\_name](#input\_network\_watcher\_name) | (Optional) Custom name for the Azure Network Watcher | `string` | `"default"` | no |
| <a name="input_networking_rg_name"></a> [networking\_rg\_name](#input\_networking\_rg\_name) | Networking resource group name | `string` | `"networking-rg-01"` | no |
| <a name="input_regional_replica_count"></a> [regional\_replica\_count](#input\_regional\_replica\_count) | The number of replicas of the Shared Image Gallery to be created in the target region. Must be between 1 and 5. | `number` | `1` | no |
| <a name="input_regional_tags"></a> [regional\_tags](#input\_regional\_tags) | Regional level tags | `map(string)` | n/a | yes |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | Name prefix used for resources | `string` | n/a | yes |
| <a name="input_sas_end_date"></a> [sas\_end\_date](#input\_sas\_end\_date) | value | `string` | n/a | yes |
| <a name="input_sas_start_date"></a> [sas\_start\_date](#input\_sas\_start\_date) | value | `string` | n/a | yes |
| <a name="input_storage_account_type"></a> [storage\_account\_type](#input\_storage\_account\_type) | The type of storage account to use for the Shared Image Gallery. Possible values are Standard\_LRS, Standard\_GRS, Standard\_RAGRS, Standard\_ZRS, Premium\_LRS, Premium\_ZRS | `string` | `"Standard_LRS"` | no |
| <a name="input_vm_image_definitions"></a> [vm\_image\_definitions](#input\_vm\_image\_definitions) | n/a | <pre>list(object({<br/>    name                 = string<br/>    os_type              = string<br/>    identifier_publisher = string<br/>    identifier_offer     = string<br/>    identifier_sku       = string<br/>    hyper_v_generation   = string<br/>    managed_image_id     = optional(string, null) # Optional: source for image version<br/><br/>    # Make purchase_plan attributes optional<br/>    purchase_plan_name      = optional(string)<br/>    purchase_plan_publisher = optional(string)<br/>    purchase_plan_product   = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_vmdiag_storageaccount_name"></a> [vmdiag\_storageaccount\_name](#input\_vmdiag\_storageaccount\_name) | (Optional) Custom name for the VM Diagnostic Logs Storage Account | `string` | `"default"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_additional_resource_groups"></a> [additional\_resource\_groups](#output\_additional\_resource\_groups) | n/a |
| <a name="output_application_rg_name"></a> [application\_rg\_name](#output\_application\_rg\_name) | n/a |
| <a name="output_file_uploads"></a> [file\_uploads](#output\_file\_uploads) | n/a |
| <a name="output_installs_container_id"></a> [installs\_container\_id](#output\_installs\_container\_id) | n/a |
| <a name="output_installs_container_name"></a> [installs\_container\_name](#output\_installs\_container\_name) | n/a |
| <a name="output_key_vault_rg_id"></a> [key\_vault\_rg\_id](#output\_key\_vault\_rg\_id) | n/a |
| <a name="output_key_vault_rg_name"></a> [key\_vault\_rg\_name](#output\_key\_vault\_rg\_name) | n/a |
| <a name="output_management_rg_name"></a> [management\_rg\_name](#output\_management\_rg\_name) | n/a |
| <a name="output_network_rg_name"></a> [network\_rg\_name](#output\_network\_rg\_name) | n/a |
| <a name="output_network_watcher_name"></a> [network\_watcher\_name](#output\_network\_watcher\_name) | n/a |
| <a name="output_shellscripts_container_id"></a> [shellscripts\_container\_id](#output\_shellscripts\_container\_id) | n/a |
| <a name="output_storage_account_ars_id"></a> [storage\_account\_ars\_id](#output\_storage\_account\_ars\_id) | n/a |
| <a name="output_storage_account_ars_name"></a> [storage\_account\_ars\_name](#output\_storage\_account\_ars\_name) | n/a |
| <a name="output_storage_account_docs_id"></a> [storage\_account\_docs\_id](#output\_storage\_account\_docs\_id) | n/a |
| <a name="output_storage_account_docs_name"></a> [storage\_account\_docs\_name](#output\_storage\_account\_docs\_name) | n/a |
| <a name="output_storage_account_flowlogs_id"></a> [storage\_account\_flowlogs\_id](#output\_storage\_account\_flowlogs\_id) | n/a |
| <a name="output_storage_account_flowlogs_name"></a> [storage\_account\_flowlogs\_name](#output\_storage\_account\_flowlogs\_name) | n/a |
| <a name="output_storage_account_install_id"></a> [storage\_account\_install\_id](#output\_storage\_account\_install\_id) | n/a |
| <a name="output_storage_account_install_name"></a> [storage\_account\_install\_name](#output\_storage\_account\_install\_name) | n/a |
| <a name="output_storage_account_vm_diag_sas"></a> [storage\_account\_vm\_diag\_sas](#output\_storage\_account\_vm\_diag\_sas) | n/a |
| <a name="output_storage_account_vmdiag_id"></a> [storage\_account\_vmdiag\_id](#output\_storage\_account\_vmdiag\_id) | n/a |
| <a name="output_storage_account_vmdiag_name"></a> [storage\_account\_vmdiag\_name](#output\_storage\_account\_vmdiag\_name) | n/a |
| <a name="output_vm_image_definitions"></a> [vm\_image\_definitions](#output\_vm\_image\_definitions) | n/a |
| <a name="output_vmdiag_endpoint"></a> [vmdiag\_endpoint](#output\_vmdiag\_endpoint) | n/a |
<!-- END_TF_DOCS -->


## Contributing

[Start Here](CONTRIBUTING.md)

## License

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/license/mit/)

## Contact Us

[Coalfire](https://coalfire.com/)

### Copyright

Copyright © 2023 Coalfire Systems Inc.
## Tree
```
.
|-- CONTRIBUTING.md
|-- LICENSE
|-- License.md
|-- README.md
|-- blob_ars.tf
|-- blob_docs.tf
|-- blob_flowlog.tf
|-- blob_install.tf
|-- blob_vm_diag.tf
|-- coalfire_logo.png
|-- image_gallery.tf
|-- locals.tf
|-- network_watcher.tf
|-- outputs.tf
|-- release-please-config.json
|-- required_providers.tf
|-- resource_group.tf
|-- share_cloudshell.tf
|-- update-readme-tree.sh
|-- variables.tf
```
