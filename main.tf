resource "azurerm_kubernetes_cluster" "default" {
  name                              = local.aks_cluster_name
  resource_group_name               = var.resource_group_name
  location                          = var.location
  kubernetes_version                = var.kubernetes_version
  node_resource_group               = "${local.aks_cluster_name}-nodes-rg"
  private_cluster_enabled           = var.private_cluster_enabled
  public_network_access_enabled     = var.public_network_access_enabled
  role_based_access_control_enabled = true
  local_account_disabled            = true
  sku_tier                          = var.sku_tier
  #dns_prefix_private_cluster        = replace("${local.aks_cluster_name}", "-", "")
  dns_prefix           = replace("${local.aks_cluster_name}", "_", "-") #dns_prefix must contain between 2 and 45 characters. The name can contain only letters, numbers, and hyphens
  azure_policy_enabled = var.azure_policy_enabled

  default_node_pool {
    name                 = "system"
    node_count           = var.default_node_config.enable_auto_scaling ? null : lookup(var.default_node_config, "node_count", 2)
    max_pods             = var.max_pods
    vm_size              = var.default_node_config.vm_size
    enable_auto_scaling  = lookup(var.default_node_config, "enable_auto_scaling", true)
    min_count            = var.default_node_config.enable_auto_scaling ? lookup(var.default_node_config, "min_count", 2) : null
    max_count            = var.default_node_config.enable_auto_scaling ? lookup(var.default_node_config, "max_count", 5) : null
    fips_enabled         = true
    node_labels          = var.kubernetes_default_node_labels
    orchestrator_version = var.kubernetes_version
    vnet_subnet_id       = var.vnet_subnet_id
    tags                 = var.tags
  }

  identity {
    type = "SystemAssigned"
  }

  azure_active_directory_role_based_access_control {
    managed            = true
    azure_rbac_enabled = true
    admin_group_object_ids = [
      azuread_group.admin.object_id
    ]
  }

  maintenance_window {
    dynamic "allowed" {
      for_each = toset(var.maintenance_window.days)
      content {
        day   = allowed.key
        hours = var.maintenance_window.hours
      }
    }
  }

  network_profile {
    network_plugin     = var.network_plugin
    network_policy     = var.network_plugin == "azure" ? "azure" : "calico"
    outbound_type      = "userAssignedNATGateway"
    docker_bridge_cidr = "172.17.0.0/16"
    service_cidr       = "172.18.0.0/16"
    dns_service_ip     = "172.18.10.10"

    nat_gateway_profile {
      idle_timeout_in_minutes = 10
    }
  }

  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "5m"
  }

  dynamic "ingress_application_gateway" {
    for_each = var.appgw_id != null ? [1] : []
    content {
      gateway_id = var.appgw_id
    }
  }

  oms_agent {
    log_analytics_workspace_id = var.diag_log_analytics_id
  }

  tags = var.tags

}

module "diag" {
  source                = "../coalfire-diagnostic/"
  diag_log_analytics_id = var.diag_log_analytics_id
  resource_id           = azurerm_kubernetes_cluster.default.id
  resource_type         = "aks"
}