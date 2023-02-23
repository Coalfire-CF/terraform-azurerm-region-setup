resource "azurerm_storage_account" "install_blob" {
  name                            = length("${local.storage_name_prefix}sainstalls") <= 24 ? "${local.storage_name_prefix}sainstalls" : "${var.location_abbreviation}mp${var.app_abbreviation}sainstalls"
  resource_group_name             = azurerm_resource_group.management.name
  location                        = var.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2"
  allow_nested_items_to_be_public = false
  enable_https_traffic_only       = true

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

resource "azurerm_storage_container" "shellscripts_container" {
  name                  = "shellscripts"
  storage_account_name  = azurerm_storage_account.install_blob.name
  container_access_type = "private"
}

# Will be used to store licenses/executables for mgmt plane
resource "azurerm_storage_container" "installfile_container" {
  name                  = "install-files"
  storage_account_name  = azurerm_storage_account.install_blob.name
  container_access_type = "private"
}

resource "azurerm_role_assignment" "tstate_kv_crypto_user_install_blob" {
  scope                = var.core_kv_id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_storage_account.install_blob.identity.0.principal_id

  depends_on = [
    azurerm_storage_account.install_blob
  ]
}

resource "azurerm_storage_account_customer_managed_key" "enable_install_blob_cmk" {
  storage_account_id = azurerm_storage_account.install_blob.id
  key_vault_id       = var.core_kv_id
  key_name           = "install-cmk"

  depends_on = [
    azurerm_role_assignment.tstate_kv_crypto_user_install_blob
  ]
}

resource "azurerm_storage_blob" "linb_domainjoin" {
  name                   = "ud_linux_join_ad.sh"
  storage_account_name   = azurerm_storage_account.install_blob.name
  storage_container_name = "shellscripts"
  type                   = "Block"
  source                 = "../../../../shellscripts/linux/ud_linux_join_ad.sh"
}

resource "azurerm_storage_blob" "linb_monitor_agent" {
  name                   = "ud_linux_monitor_agent.sh"
  storage_account_name   = azurerm_storage_account.install_blob.name
  storage_container_name = "shellscripts"
  type                   = "Block"
  source                 = "../../../../shellscripts/linux/ud_linux_monitor_agent.sh"
}

module "diag_install_blob_sa" {
  source                = "github.com/Coalfire-CF/ACE-Azure-Diagnostics"
  diag_log_analytics_id = var.diag_log_analytics_id
  resource_id           = azurerm_storage_account.install_blob.id
  resource_type         = "sa"
}
