module "ars_sa" {
  source                = "github.com/Coalfire-CF/terraform-azurerm-storage-account?ref=v1.0.1"
  name                  = local.ars_storageaccount_name
  resource_group_name   = azurerm_resource_group.management.name
  location              = var.location
  account_kind          = "StorageV2"
  ip_rules              = var.ip_for_remote_access
  diag_log_analytics_id = var.diag_log_analytics_id
  virtual_network_subnet_ids = var.fw_virtual_network_subnet_ids

  tags = merge({
    Function = "Storage"
    Plane    = "Management"
  }, var.global_tags, var.regional_tags)

  public_network_access_enabled = true
  enable_customer_managed_key   = true
  cmk_key_vault_id              = var.core_kv_id
}


