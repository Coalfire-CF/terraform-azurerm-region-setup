resource "azurerm_storage_account" "cloudShell" {
  name                            = length("${local.storage_name_prefix}sacloudshell") <= 24 ? "${local.storage_name_prefix}sacloudshell" : "${var.location_abbreviation}mp${var.app_abbreviation}sacloudshell"
  resource_group_name             = azurerm_resource_group.management.name
  location                        = var.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2"
  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = false

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      customer_managed_key # required by https://github.com/hashicorp/terraform-provider-azurerm/issues/16085
    ]
  }

  identity {
    type = "SystemAssigned"
  }

  tags = merge({
    Function = "Storage"
    Plane    = "Management"
  }, var.global_tags, var.regional_tags)
}

resource "azurerm_role_assignment" "tstate_kv_crypto_user_cloudshell" {
  scope                = var.core_kv_id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_storage_account.cloudShell.identity[0].principal_id

  depends_on = [
    azurerm_storage_account.cloudShell
  ]
}

resource "azurerm_storage_account_customer_managed_key" "enable_cloudShell_cmk" {
  storage_account_id = azurerm_storage_account.cloudShell.id
  key_vault_id       = var.core_kv_id
  key_name           = "cloudshell-cmk"

  depends_on = [
    azurerm_role_assignment.tstate_kv_crypto_user_cloudshell
  ]
}

module "diag_cloudshell_sa" {
  source                = "github.com/Coalfire-CF/terraform-azurerm-diagnostics?ref=v1.0.0"
  diag_log_analytics_id = var.diag_log_analytics_id
  resource_id           = azurerm_storage_account.cloudShell.id
  resource_type         = "sa"
}
