resource "azuread_group" "admin" {
  display_name     = "${local.aks_cluster_name}_admin_group"
  security_enabled = true
  #prevent_duplicate_names = true
}

resource "azurerm_role_assignment" "kv_aks_secret_provider" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_kubernetes_cluster.default.key_vault_secrets_provider.0.secret_identity.0.object_id

  depends_on = [
    azurerm_kubernetes_cluster.default
  ]
}