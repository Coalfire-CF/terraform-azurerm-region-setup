data "azurerm_client_config" "current" {}
resource "azurerm_storage_account" "ars_sa" {
  name                            = length("${local.storage_name_prefix}saarsvault") <= 24 ? "${local.storage_name_prefix}saarsvault" : "${var.location_abbreviation}mp${var.app_abbreviation}saarsvault"
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

  # test
  # network_rules {
  #   default_action = "Deny"
  #   ip_rules       = var.ip_for_remote_access
  #   #virtual_network_subnet_ids = [data.terraform_remote_state.core.outputs.core_vnet_subnet_ids[1]]
  #   virtual_network_subnet_ids = [var.firewall_vnet_subnet_ids]
  # }

  tags = merge({
    Function = "Storage"
    Plane    = "Management"
  }, var.global_tags, var.regional_tags)

}

resource "azurerm_role_assignment" "tstate_kv_crypto_user_ars" {
  scope                = var.core_kv_id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_storage_account.ars_sa.identity.0.principal_id
}

resource "azurerm_storage_account_customer_managed_key" "enable_ars_cmk" {
  storage_account_id = azurerm_storage_account.ars_sa.id
  key_vault_id       = var.core_kv_id
  key_name           = "ars-cmk"
  depends_on = [
    azurerm_role_assignment.tstate_kv_crypto_user_ars
  ]
}


### Monitoring ###
# note: only for blob storage. not file/queue/table
# note: see - https://github.com/hashicorp/terraform-provider-azurerm/issues/8275 
# for why the target resource ID has different different settings
module "diag_ars_sa" {
  source                = "git@github.com:Coalfire-CF/ACE-Azure-Diagnostics.git?ref=v1.0.1"
  diag_log_analytics_id = var.diag_log_analytics_id
  resource_id           = azurerm_storage_account.ars_sa.id
  resource_type         = "sa"
}