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
#Commenting out till we decide on a direction for where to store shell scripts

resource "azurerm_storage_blob" "linb_domainjoin" {
  count                  = var.linux_domain_join_script_path != "none" ? 1 : 0 #example conditional
  name                   = "ud_linux_join_ad.sh"
  storage_account_name   = module.installs_sa.name # this will need to be updated to something like module.installs_sa.azurerm_storage_account etc
  storage_container_name = "shellscripts"
  type                   = "Block"
  source                 = var.linux_domain_join_script_path
}

# resource "azurerm_storage_blob" "linb_monitor_agent" {
#   name                   = "ud_linux_monitor_agent.sh"
#   storage_account_name   = azurerm_storage_account.install_blob.name # this will need to be updated to something like module.installs_sa.azurerm_storage_account etc
#   storage_container_name = "shellscripts"
#   type                   = "Block"
#   source                 = "../../../../shellscripts/linux/ud_linux_monitor_agent.sh" ## see above
# }

# TODOs

# Create input var for file path to ud_linux_join_ad.sh

# Create input var for file path to ud_linux_monitor_agent.sh

# uncomment the storage blob resources above

# make the above storage blob resources conditional on the input var (see above example conditional)

# Update README to document new optional variables
