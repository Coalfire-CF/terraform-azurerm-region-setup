module "installs_sa" {
  source                     = "git::https://github.com/Coalfire-CF/terraform-azurerm-storage-account?ref=v1.1.0"
  name                       = local.installs_storageaccount_name
  resource_group_name        = azurerm_resource_group.management.name
  location                   = var.location
  account_kind               = "StorageV2"
  ip_rules                   = var.ip_for_remote_access
  diag_log_analytics_id      = var.diag_log_analytics_id
  virtual_network_subnet_ids = var.fw_virtual_network_subnet_ids
  tags = merge({
    Function = "Storage"
    Plane    = "Management"
  }, var.global_tags, var.regional_tags)

  public_network_access_enabled = var.public_network_access_enabled
  enable_customer_managed_key   = var.enable_customer_managed_key
  cmk_key_vault_id              = var.core_kv_id
  cmk_key_name                  = var.installs_cmk_key_name
  storage_containers = [
    "shellscripts", "install-files", "uploads"
  ]
}

resource "azurerm_storage_blob" "file_upload" {
  depends_on             = [module.installs_sa]
  count                  = length(var.file_upload_paths)
  name                   = basename(var.file_upload_paths[count.index])
  storage_account_name   = module.installs_sa.name
  storage_container_name = "uploads"
  type                   = "Block"
  source                 = var.file_upload_paths[count.index]
}


