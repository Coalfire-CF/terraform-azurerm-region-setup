resource "azurerm_kubernetes_cluster_node_pool" "user_pools" {
  for_each              = var.user_node_pools
  name                  = each.key
  kubernetes_cluster_id = azurerm_kubernetes_cluster.default.id
  vm_size               = each.value.vm_size
  enable_auto_scaling   = true
  enable_node_public_ip = false
  fips_enabled          = true
  max_pods              = try(each.value.max_pods, var.max_pods)
  node_labels           = try(each.value.node_labels, {})
  node_taints           = try(each.value.node_taints, [])
  orchestrator_version  = var.kubernetes_version
  os_disk_size_gb       = each.value.os_disk_size_gb
  max_count             = each.value.max_count
  min_count             = each.value.min_count
  vnet_subnet_id        = var.vnet_subnet_id
  tags                  = var.tags
  zones                 = var.zones
}