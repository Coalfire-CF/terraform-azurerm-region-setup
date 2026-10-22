# Storage for Azure Cloud Shell. Cloud Shell mounts an Azure Files share, so the
# private endpoint targets the file subresource.
module "cloudshell_sa" {
  source                = "git::https://github.com/Coalfire-CF/terraform-azurerm-storage-account?ref=v3.0.0"
  name                  = local.cloudshell_storageaccount_name
  resource_group_name   = azurerm_resource_group.management.name
  location              = var.location
  account_kind          = "StorageV2"
  replication_type      = var.storage_replication_type
  diag_log_analytics_id = var.diag_log_analytics_id

  public_network_access      = var.public_network_access
  ip_rules                   = var.ip_for_remote_access
  virtual_network_subnet_ids = var.sa_subnet_ids
  shared_access_key_enabled  = var.cloudshell_shared_access_key_enabled

  endpoint_subnet_id                 = var.private_endpoint_subnet_id
  private_endpoint_subresource_names = ["file"]
  private_dns_zone_id                = var.file_private_dns_zone_id

  enable_customer_managed_key = var.enable_customer_managed_key
  cmk_key_vault_id            = var.core_kv_id
  cmk_key_name                = var.cloudshell_cmk_key_name

  blob_delete_retention_days      = var.blob_delete_retention_days
  container_delete_retention_days = var.container_delete_retention_days
  share_delete_retention_days     = var.share_delete_retention_days

  tags = merge({
    Function = "Storage"
    Plane    = "Management"
  }, local.tags)
}
