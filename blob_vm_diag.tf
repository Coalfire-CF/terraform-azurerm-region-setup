module "vm_diag" {
  source                     = "git::https://github.com/Coalfire-CF/terraform-azurerm-storage-account?ref=v1.0.4"
  name                       = local.vmdiag_storageaccount_name
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

  public_network_access_enabled = var.enable_sa_public_access
  enable_customer_managed_key   = true
  cmk_key_vault_id              = var.core_kv_id
}

data "azurerm_storage_account_sas" "vm_diag_sas" {
  connection_string = module.vm_diag.primary_connection_string
  https_only        = true

  resource_types {
    service   = true
    container = true
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = true
    file  = false
  }

  start  = var.sas_start_date
  expiry = var.sas_end_date

  permissions {
    read    = true
    write   = true
    delete  = false
    list    = false
    add     = true
    create  = true
    update  = true
    process = true
    tag     = false
    filter  = false
  }
}
