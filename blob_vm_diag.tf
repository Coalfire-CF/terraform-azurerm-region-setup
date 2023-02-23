resource "azurerm_storage_account" "vm_diag" {
  name                            = length("${local.storage_name_prefix}savmdiag") <= 24 ? "${local.storage_name_prefix}savmdiag" : "${var.location_abbreviation}mp${var.app_abbreviation}savmdiag"
  resource_group_name             = azurerm_resource_group.management.name
  location                        = var.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2"
  enable_https_traffic_only       = true
  allow_nested_items_to_be_public = false

  lifecycle {
    prevent_destroy = true
  }
  tags = merge({
    Function = "Storage"
    Plane    = "Management"
  }, var.global_tags, var.regional_tags)
}

data "azurerm_storage_account_sas" "vm_diag_sas" {
  connection_string = azurerm_storage_account.vm_diag.primary_connection_string
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

module "diag_vm_diag_sa" {
  source                = "github.com/Coalfire-CF/ACE-Azure-Diagnostics?ref=releases/latest"
  diag_log_analytics_id = var.diag_log_analytics_id
  resource_id           = azurerm_storage_account.vm_diag.id
  resource_type         = "sa"
}
