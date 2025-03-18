module "installs_sa" {
  source                     = "github.com/Coalfire-CF/terraform-azurerm-storage-account?ref=v1.0.1"
  name                       = local.installs_storageaccount_name
  resource_group_name        = var.mgmt_rg_name
  location                   = var.location
  account_kind               = "StorageV2"
  ip_rules                   = var.ip_for_remote_access
  diag_log_analytics_id      = var.diag_log_analytics_id
  virtual_network_subnet_ids = var.fw_virtual_network_subnet_ids
  tags = merge({
    Function = "Storage"
    Plane    = "Management"
  }, var.global_tags, var.regional_tags)

  public_network_access_enabled = true
  enable_customer_managed_key   = true
  cmk_key_vault_id              = var.core_kv_id
  storage_containers = [
    "shellscripts", "install-files"
  ]
}

resource "azurerm_storage_blob" "linux_domainjoin" {
  count                  = var.linux_domain_join_script_path != "none" ? 1 : 0
  name                   = basename(var.linux_domain_join_script_path)
  storage_account_name   = module.installs_sa.name
  storage_container_name = "shellscripts"
  type                   = "Block"
  source                 = var.linux_domain_join_script_path
}

resource "azurerm_storage_blob" "linux_monitor_agent" {
  count                  = var.linux_monitor_agent_script_path != "none" ? 1 : 0
  name                   = basename(var.linux_monitor_agent_script_path)
  storage_account_name   = module.installs_sa.name
  storage_container_name = "shellscripts"
  type                   = "Block"
  source                 = var.linux_monitor_agent_script_path
}

resource "azurerm_storage_blob" "file_upload" {
  # for_each = var.file_upload_paths
  count                  = length(var.file_upload_paths)
  name                   = basename(var.file_upload_paths[count.index])
  storage_account_name   = module.installs_sa.name
  storage_container_name = "shellscripts"
  type                   = "Block"
  source                 = var.var.file_upload_paths[count.index]
}


