# Coalfire Azure Region Setup Module

## Description

This module creates basic Azure resources that are foundational to environment set up in a specific Azure region. 

### Dependencies

This module is dependent on the Security-Core module. 

### Resource List

- Azure Monitor
- Storage Account Blob and Container for terraform remote state lock
- Storage Account Blobs for
  - backup
  - flowlogs
  - monitor logs
  - installer files
  - Terraform remote state
- A stopinator Azure function - Not ported yet

### Stopinator Details

 The stopinator Azure function created within this module is triggered every 5 minutes.  Instances that should be stopped should have the following tags:

- start_time: The time (24 hour format) that the instance should be started
- stop_time:  The time (24 hour format) that the instance should be stopped
- stop_weekend: If this tag is added, the instance will be stopped during the weekend

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| subscription\_id | The Azure subscription ID resources are being deployed into | `string` | n/a | yes |
| location | The Azure location/region to create things in | `string` | n/a | yes |
| create\_monitor | Whether or not to create Azure Monitor resources | `bool` | n/a | yes |
| default\_azure\_location | The default Azure location/region to create resources in | `string` | n/a | yes |
| is\_gov | Whether or not resources will be deployed in a GovCloud region | `bool` | n/a | yes |
| resource\_prefix | The prefix for the storage account names | `string` | n/a | yes |
| function\_time\_zone | The time zone for the stopinator Azure function | `string` | `"US/Eastern"` | no |
| diag_log_analytics_id | ID of the Log Analytics Workspace diagnostic logs should be sent to | string | N/A | yes |
| additional_resource_groups | Additional resource groups to create | list(string) | [] | no |

### Outputs

| Name | Description |
|------|-------------|
| rhel8\_id | The id of the rhel image from image gallery |
| storage\_account\_ars\_id | The id of the Azure Recovery Services storage account |
| storage\_account\_flowlogs\_id | The id of the flowlog storage account |
| storage\_account\_install\_id | The id of the installs storage account |
| storage\_account\_tfstate\_id | The id of the tfstate storage account |
| windows\_golden\_id | The id of the windows image from image gallery |
| windows\_ad\_id | The id of the windows AD image from image gallery |
| additional_resource_groups | Map with additional resource groups with format `{name = id}` |

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ars_sa"></a> [ars\_sa](#module\_ars\_sa) | github.com/Coalfire-CF/ACE-Azure-StorageAccount | n/a |
| <a name="module_diag_cloudshell_sa"></a> [diag\_cloudshell\_sa](#module\_diag\_cloudshell\_sa) | github.com/Coalfire-CF/ACE-Azure-Diagnostics | n/a |
| <a name="module_docs_sa"></a> [docs\_sa](#module\_docs\_sa) | github.com/Coalfire-CF/ACE-Azure-StorageAccount | n/a |
| <a name="module_flowlogs_sa"></a> [flowlogs\_sa](#module\_flowlogs\_sa) | github.com/Coalfire-CF/ACE-Azure-StorageAccount | n/a |
| <a name="module_installs_sa"></a> [installs\_sa](#module\_installs\_sa) | github.com/Coalfire-CF/ACE-Azure-StorageAccount | n/a |
| <a name="module_vm_diag"></a> [vm\_diag](#module\_vm\_diag) | github.com/Coalfire-CF/ACE-Azure-StorageAccount | n/a |

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
| [azurerm_shared_image.rhel8-golden](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/shared_image) | resource |
| [azurerm_shared_image.windows2019](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/shared_image) | resource |
| [azurerm_shared_image.windows2019ad](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/shared_image) | resource |
| [azurerm_shared_image.windows2019ca](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/shared_image) | resource |
| [azurerm_shared_image_gallery.packerimages](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/shared_image_gallery) | resource |
| [azurerm_storage_account.cloudShell](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_account_customer_managed_key.enable_cloudShell_cmk](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_customer_managed_key) | resource |
| [azurerm_storage_account_sas.vm_diag_sas](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/storage_account_sas) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_resource_groups"></a> [additional\_resource\_groups](#input\_additional\_resource\_groups) | Additional resource groups to create | `list(string)` | `[]` | no |
| <a name="input_admin_principal_ids"></a> [admin\_principal\_ids](#input\_admin\_principal\_ids) | List of principal ID's for all admins | `set(string)` | n/a | yes |
| <a name="input_app_abbreviation"></a> [app\_abbreviation](#input\_app\_abbreviation) | The prefix for the blob storage account names | `string` | n/a | yes |
| <a name="input_app_rg_name"></a> [app\_rg\_name](#input\_app\_rg\_name) | Application plane resource group name | `string` | `"application-rg-1"` | no |
| <a name="input_core_kv_id"></a> [core\_kv\_id](#input\_core\_kv\_id) | n/a | `string` | n/a | yes |
| <a name="input_diag_log_analytics_id"></a> [diag\_log\_analytics\_id](#input\_diag\_log\_analytics\_id) | ID of the Log Analytics Workspace diagnostic logs should be sent to | `string` | n/a | yes |
| <a name="input_firewall_vnet_subnet_ids"></a> [firewall\_vnet\_subnet\_ids](#input\_firewall\_vnet\_subnet\_ids) | Subnet ID's that should be allowed for the firewall | `list(string)` | `[]` | no |
| <a name="input_fw_virtual_network_subnet_ids"></a> [fw\_virtual\_network\_subnet\_ids](#input\_fw\_virtual\_network\_subnet\_ids) | List of subnet ids for the firewall | `list(string)` | `[]` | no |
| <a name="input_global_tags"></a> [global\_tags](#input\_global\_tags) | Global level tags | `map(string)` | n/a | yes |
| <a name="input_ip_for_remote_access"></a> [ip\_for\_remote\_access](#input\_ip\_for\_remote\_access) | This is the same as 'cidrs\_for\_remote\_access' but without the /32 on each of the files. The 'ip\_rules' in the storage account will not accept a '/32' address and I gave up trying to strip and convert the values over | `list(any)` | n/a | yes |
| <a name="input_key_vault_rg_name"></a> [key\_vault\_rg\_name](#input\_key\_vault\_rg\_name) | Key Vault resource group name | `string` | `"keyvault-rg-01"` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure location/region to create resources in | `string` | n/a | yes |
| <a name="input_location_abbreviation"></a> [location\_abbreviation](#input\_location\_abbreviation) | The  Azure location/region in 4 letter code | `string` | n/a | yes |
| <a name="input_mgmt_rg_name"></a> [mgmt\_rg\_name](#input\_mgmt\_rg\_name) | Management plane resource group name | `string` | `"management-rg-1"` | no |
| <a name="input_networking_rg_name"></a> [networking\_rg\_name](#input\_networking\_rg\_name) | Networking resource group name | `string` | `"networking-rg-01"` | no |
| <a name="input_regional_tags"></a> [regional\_tags](#input\_regional\_tags) | Regional level tags | `map(string)` | n/a | yes |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | Name prefix used for resources | `string` | n/a | yes |
| <a name="input_sas_end_date"></a> [sas\_end\_date](#input\_sas\_end\_date) | value | `string` | n/a | yes |
| <a name="input_sas_start_date"></a> [sas\_start\_date](#input\_sas\_start\_date) | value | `string` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | The Azure subscription ID where resources are being deployed into | `string` | n/a | yes |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | The Azure tenant ID that owns the deployed resources | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_additional_resource_groups"></a> [additional\_resource\_groups](#output\_additional\_resource\_groups) | n/a |
| <a name="output_application_rg_name"></a> [application\_rg\_name](#output\_application\_rg\_name) | n/a |
| <a name="output_installs_container_id"></a> [installs\_container\_id](#output\_installs\_container\_id) | n/a |
| <a name="output_installs_container_name"></a> [installs\_container\_name](#output\_installs\_container\_name) | n/a |
| <a name="output_key_vault_rg_id"></a> [key\_vault\_rg\_id](#output\_key\_vault\_rg\_id) | n/a |
| <a name="output_key_vault_rg_name"></a> [key\_vault\_rg\_name](#output\_key\_vault\_rg\_name) | n/a |
| <a name="output_management_rg_name"></a> [management\_rg\_name](#output\_management\_rg\_name) | n/a |
| <a name="output_network_rg_name"></a> [network\_rg\_name](#output\_network\_rg\_name) | n/a |
| <a name="output_network_watcher_name"></a> [network\_watcher\_name](#output\_network\_watcher\_name) | n/a |
| <a name="output_rhel8_id"></a> [rhel8\_id](#output\_rhel8\_id) | n/a |
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
| <a name="output_vmdiag_endpoint"></a> [vmdiag\_endpoint](#output\_vmdiag\_endpoint) | n/a |
| <a name="output_windows_ad_id"></a> [windows\_ad\_id](#output\_windows\_ad\_id) | n/a |
| <a name="output_windows_ca_id"></a> [windows\_ca\_id](#output\_windows\_ca\_id) | n/a |
| <a name="output_windows_golden_id"></a> [windows\_golden\_id](#output\_windows\_golden\_id) | n/a |
<!-- END_TF_DOCS -->