# Coalfire Region Setup Module

## Description

This module creates basic Azure resources that are foundational to environment set up.

## Resource List

- Azure Monitor
- Storage Account Blob and Container for terraform remote state lock
- Storage Account Blobs for
  - backup
  - flowlogs
  - monitor logs
  - installer files
  - terraform remote state
- A stopinator Azure function - Not ported yet

## Stopinator Details

 The stopinator Azure function created within this module is triggered every 5 minutes.  Instances that should be stopped should have the following tags:

- start_time: The time (24 hour format) that the instance should be started
- stop_time:  The time (24 hour format) that the instance should be stopped
- stop_weekend: If this tag is added, the instance will be stopped during the weekend

## Inputs

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

## Outputs

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
