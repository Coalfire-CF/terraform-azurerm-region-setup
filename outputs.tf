output "aks_id" {
  description = "The Kubernetes Managed Cluster ID."
  value       = azurerm_kubernetes_cluster.default.id
}

output "aks_fqdn" {
  description = "The FQDN of the Azure Kubernetes Managed Cluster."
  value       = azurerm_kubernetes_cluster.default.private_fqdn
}

output "aks_principal_id" {
  description = "The Principal ID associated with this Managed Service Identity."
  value       = azurerm_kubernetes_cluster.default.identity.0.principal_id
}

output "aks_aad_group_name" {
  description = "Name of the AD group that grants admin access to the AKS cluster"
  value       = azuread_group.admin.display_name
}

output "aks_aad_group_object_id" {
  description = "Object ID of the AD group that grants admin access to the AKS cluster"
  value       = azuread_group.admin.object_id
}