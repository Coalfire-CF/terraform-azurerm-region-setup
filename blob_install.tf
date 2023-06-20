module "installs_sa" {
  source                     = "github.com/Coalfire-CF/ACE-Azure-StorageAccount"
  name                       = "${replace(var.resource_prefix, "-", "")}sainstalls"
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

  public_network_access_enabled = true
  enable_customer_managed_key   = true
  cmk_key_vault_id              = var.core_kv_id
  storage_containers = [
    "shellscripts", "install-files"
  ]
}
# Commenting out till we decide on a direction for where to store shell scripts
# resource "azurerm_storage_blob" "linb_domainjoin" {
#   name                   = "ud_linux_join_ad.sh"
#   storage_account_name   = azurerm_storage_account.install_blob.name
#   storage_container_name = "shellscripts"
#   type                   = "Block"
#   source                 = "../../../../shellscripts/linux/ud_linux_join_ad.sh"
# }

# resource "azurerm_storage_blob" "linb_monitor_agent" {
#   name                   = "ud_linux_monitor_agent.sh"
#   storage_account_name   = azurerm_storage_account.install_blob.name
#   storage_container_name = "shellscripts"
#   type                   = "Block"
#   source                 = "../../../../shellscripts/linux/ud_linux_monitor_agent.sh"
# }



