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

