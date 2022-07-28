variable "resource_group_name" {
  type        = string
  description = "The name of the resource group where the AKS cluster will be placed."
}

variable "location" {
  description = "The Azure location/region to create resources in"
  type        = string
}

variable "resource_prefix" {
  type        = string
  description = "Default prefix to use with your resource names."
}

variable "cluster_name" {
  type        = string
  description = "Name of the AKS cluster. In addition, the resource_prefix will be appended to this name."
}

variable "kubernetes_version" {
  type        = string
  description = "Version of Kubernetes. If not specified, the latest recommended version will be used at provisioning time (but won't auto-upgrade)."
  default     = null
}

variable "vnet_subnet_id" {
  type        = string
  description = "The ID of a Subnet where the Kubernetes Node Pool should exist."
}

variable "user_node_pools" {
  type        = map(any)
  description = "Map with all the user node pools and their configuration."
  default     = {}
}

variable "appgw_id" {
  type        = string
  description = "The ID of the Application Gateway to integrate with the ingress controller of this Kubernetes Cluster"
  default     = null
}

variable "zones" {
  type        = list(number)
  description = "Specifies a list of Availability Zones in which this Kubernetes Cluster should be located"
  default     = [1, 2, 3]
}

variable "private_cluster_enabled" {
  type        = bool
  description = "If enabled, this Kubernetes Cluster will have its API server only exposed on internal IP addresses"
  default     = true
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Whether public network access is allowed for this Kubernetes Cluster."
  default     = false
}

variable "sku_tier" {
  type        = string
  description = "The SKU Tier that should be used for this Kubernetes Cluster. Possible values are Free and Paid."
  default     = "Paid"
}

variable "kubernetes_default_node_labels" {
  type        = map(string)
  description = "Kubernetes labels which should be applied to nodes in the Default Node Pool."
  default     = {}
}

variable "tags" {
  description = "The tags to associate with aks resources."
  type        = map(string)
}

variable "api_server_authorized_ip_ranges" {
  type        = list(string)
  description = "The IP ranges to allow for incoming traffic to the server nodes."
  default     = null
}

variable "network_plugin" {
  type        = string
  description = "Network plugin to use for networking."
  default     = "azure"
}

variable "max_pods" {
  type        = number
  description = "The maximum number of pods that can run on each agent"
  default     = 40
}

variable "maintenance_window" {
  type = object({
    days  = list(string)
    hours = list(number)
  })
  description = "Maintenance window to perform updates"
  default = {
    days  = ["Friday", "Saturday", "Sunday"]
    hours = [0, 1, 2, 3, 4, 22, 23]
  }
}

variable "key_vault_id" {
  type        = string
  description = "Key Vault ID for the integration of an AKV as a secrets store for the AKS cluster"
}

variable "azure_policy_enabled" {
  type        = bool
  description = "Enable Azure Policy Add-On"
  default     = true
}

variable "diag_log_analytics_id" {
  description = "ID of the Log Analytics Workspace diagnostic logs should be sent to"
  type        = string
}

variable "default_node_config" {
  type        = map(any)
  description = "The default node pool configuration"
  default = {
    vm_size             = "Standard_D2_v4"
    enable_auto_scaling = true
    min_count           = 2
    max_count           = 5
  }
}