# Storage account to put FedRAMP archive documents into
resource "azurerm_storage_account" "docs_sa" {
  name                            = length("${local.storage_name_prefix}archivesa") <= 24 ? "${local.storage_name_prefix}archivesa" : "${var.location_abbreviation}mp${var.app_abbreviation}archivesa"
  resource_group_name             = azurerm_resource_group.management.name
  location                        = var.location
  account_tier                    = "Standard"
  account_replication_type        = "GRS"
  min_tls_version                 = "TLS1_2"
  enable_https_traffic_only       = true
  allow_nested_items_to_be_public = false

  identity {
    type = "SystemAssigned"
  }
  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      customer_managed_key # required by https://github.com/hashicorp/terraform-provider-azurerm/issues/16085
    ]
  }

  tags = merge({
    Function = "Storage"
    Plane    = "Management"
  }, var.global_tags, var.regional_tags)
}

resource "azurerm_storage_container" "docs_container" {
  name                  = "fedrampdocsandartifacts"
  storage_account_name  = azurerm_storage_account.docs_sa.name
  container_access_type = "private"
}

resource "azurerm_role_assignment" "tstate_kv_crypto_user_docs" {
  scope                = var.core_kv_id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_storage_account.docs_sa.identity.0.principal_id

  depends_on = [
    azurerm_storage_account.docs_sa
  ]
}

resource "azurerm_storage_account_customer_managed_key" "enable_docs_cmk" {
  storage_account_id = azurerm_storage_account.docs_sa.id
  key_vault_id       = var.core_kv_id
  key_name           = "docs-cmk"
  depends_on = [
    azurerm_role_assignment.tstate_kv_crypto_user_docs
  ]
}

module "diag_docs_sa" {
  source                = "../coalfire-diagnostic/"
  diag_log_analytics_id = var.diag_log_analytics_id
  resource_id           = azurerm_storage_account.docs_sa.id
  resource_type         = "sa"
}