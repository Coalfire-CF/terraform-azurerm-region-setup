module "flowlogs_sa" {
  source                     = "git::https://github.com/Coalfire-CF/terraform-azurerm-storage-account?ref=v3.0.0"
  name                       = local.flowlogs_storageaccount_name
  resource_group_name        = azurerm_resource_group.management.name
  location                   = var.location
  account_kind               = "StorageV2"
  ip_rules                   = var.ip_for_remote_access
  diag_log_analytics_id      = var.diag_log_analytics_id
  virtual_network_subnet_ids = var.sa_subnet_ids
  tags = merge({
    Function = "Storage"
    Plane    = "Management"
  }, local.tags)

  public_network_access           = var.public_network_access
  replication_type                = var.storage_replication_type
  shared_access_key_enabled       = false
  endpoint_subnet_id              = var.private_endpoint_subnet_id
  private_dns_zone_id             = var.blob_private_dns_zone_id
  blob_delete_retention_days      = var.blob_delete_retention_days
  container_delete_retention_days = var.container_delete_retention_days
  share_delete_retention_days     = var.share_delete_retention_days

  enable_customer_managed_key = var.enable_customer_managed_key
  cmk_key_vault_id            = var.core_kv_id
  cmk_key_name                = var.flowlogs_cmk_key_name
}
