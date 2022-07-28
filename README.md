# Azure Kubernetes Service (AKS)

AKS Deployment

## Description

This module creates an Azure AKS cluster with Federal Information Processing Standard (FIPS) enabled node pools. 

## Resource List

- Azure AKS Cluster
- System Node Pool
- User defined node pools (if provided)
- Azure Active Directory Group for Admin access
- Role assignment between AKV and AKS
- Monitor diagnostic setting

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| resource_group_name" | The name of the resource group where the AKS cluster will be placed | string | N/A | yes |
| location | The Azure location/region to create resources in | string | N/A | yes |
| resource_prefix | Default prefix to use with your resource names | string | N/A | yes |
| cluster_name | Name of the AKS cluster. In addition, the resource_prefix will be appended to this name | string | N/A | yes |
| vnet_subnet_id | The ID of a Subnet where the Kubernetes Node Pool should exist | string | N/A | yes |
| key_vault_id | Key Vault ID for the integration of an AKV as a secrets store for the AKS cluster | string | N/A | yes |
| tags | The tags to associate with aks resources | map | N/A | yes |
| diag_log_analytics_id | ID of the Log Analytics Workspace diagnostic logs should be sent to | string | N/A | yes |
| appgw_id | The ID of the Application Gateway to integrate with the ingress controller of this Kubernetes Cluster | string | null | no |
| kubernetes_version | Version of Kubernetes. If not specified, the latest recommended version will be used at provisioning time (but won't auto-upgrade) | string | null | no |
| user_node_pools | Map with all the user node pools and their configuration as shown below | map | {} | no |
| azure_policy_enabled | Enable Azure Policy Add-On | bool | true | no |
| zones | Specifies a list of Availability Zones in which this Kubernetes Cluster should be located | list(number) | [1, 2, 3] | no |
| private_cluster_enabled | If enabled, this Kubernetes Cluster will have its API server only exposed on internal IP addresses | bool | true | no |
| public_network_access_enabled | Whether public network access is allowed for this Kubernetes Cluster | bool | false | no |
| sku_tier | The SKU Tier that should be used for this Kubernetes Cluster. Possible values are Free and Paid | string | Paid | no |
| kubernetes_default_node_labels | Kubernetes labels which should be applied to nodes in the Default Node Pool | map | {} | no |
| api_server_authorized_ip_ranges | The IP ranges to allow for incoming traffic to the server nodes | list(string) | null | no |
| network_plugin | Network plugin to use for networking | string | azure | no |
| max_pods | The maximum number of pods that can run on each agent | number | 40 | no |
| maintenance_window | Maintenance window to perform updates | map | {days  = ["Friday", "Saturday", "Sunday"], hours = [0, 1, 2, 3, 4, 22, 23]} | no |

### User Node Pools Inputs

The key of the map will become the node pool name. The values are as follows:

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| vm_size | The SKU which should be used for the Virtual Machines used in this Node Pool | string | N/A | yes |
| os_disk_size_gb | The Agent Operating System disk size in GB | number | N/A | yes |
| max_count | The maximum number of nodes which should exist within this Node Pool. Valid values are between `0 and 1000` and must be greater than or equal to `min_count` | number | N/A | yes |
| min_count | The minimum number of nodes which should exist within this Node Pool. Valid values are between `0 and 1000` and must be less than or equal to `max_count` | number | N/A | yes |
| max_pods | The maximum number of pods that can run on each agent. Changing this forces a new resource to be created | number | 40 | no |
| node_labels | A map of Kubernetes labels which should be applied to nodes in this Node Pool | map | {} | no |
| node_taints | A list of Kubernetes taints which should be applied to nodes in the agent pool (e.g `key=value:NoSchedule`) | list(string) | [] | no |
| default_node_config | The default node pool configuration | map(any) | {vm_size = "Standard_D2_v4",enable_auto_scaling = true,min_count = 2,max_count = 5} | no |

## Locals

| Name | Description |
|------|-------------|
| aks_cluster_name | Name of the AKS cluster by concating resource_prefix and cluster_name variables |

## Outputs

| Name | Description |
|------|-------------|
| aks_id | The Kubernetes Managed Cluster ID |
| aks_fqdn | The FQDN of the Azure Kubernetes Managed Cluster |
| aks_principal_id | The Principal ID associated with this Managed Service Identity |
| aks_aad_group_name | Name of the AD group that grants admin access to the AKS cluster |
| aks_aad_group_object_id | Object ID of the AD group that grants admin access to the AKS cluster |

## Usage

```hcl
module "aks" {
  source                        = "../../../modules/azurerm-aks/"
  resource_group_name           = "${local.app_resource_prefix}-aks1-rg"
  location                      = var.location
  resource_prefix               = local.app_resource_prefix
  cluster_name                  = "aks1"
  kubernetes_version            = "1.22.6"
  vnet_subnet_id                = module.ath.app_vnet_subnet_ids["${local.app_resource_prefix}-aks1_active1-sn"]
  appgw_id                      = "TODO"
  tags                          = local.tags
  diag_log_analytics_id         = data.terraform_remote_state.core.outputs.core_la_id
  key_vault_id                  = data.terraform_remote_state.usgv_key_vaults.outputs.usgv_app_kv_id

  # User Defined Node Pools
  user_node_pools = {
    dev = {
      vm_size         = "Standard_D2_v4"
      os_disk_size_gb = 100
      max_count       = 2
      min_count       = 1
    }

    prod = {
      vm_size         = "Standard_D4_v4"
      os_disk_size_gb = 200
      max_count       = 50
      min_count       = 5
    }
  }
}
```
