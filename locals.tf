locals {
  storage_name_prefix = replace(var.resource_prefix, "-", "")

  # Default names for resources
  compute_gallery_name           = var.compute_gallery_name != "default" ? var.compute_gallery_name : "${replace(var.resource_prefix, "-", "_")}_imagegallery_1"
  cloudshell_storageaccount_name = var.cloudshell_storageaccount_name != "default" ? var.cloudshell_storageaccount_name : length("${local.storage_name_prefix}sacloudshell") <= 24 ? "${local.storage_name_prefix}sacloudshell" : "${var.location_abbreviation}mp${var.app_abbreviation}sacloudshell"
  ars_storageaccount_name        = var.ars_storageaccount_name != "default" ? var.ars_storageaccount_name : "${replace(var.resource_prefix, "-", "")}saarsvault"
  docs_storageaccount_name       = var.docs_storageaccount_name != "default" ? var.docs_storageaccount_name : "${replace(var.resource_prefix, "-", "")}docs"
  flowlogs_storageaccount_name   = var.flowlogs_storageaccount_name != "default" ? var.flowlogs_storageaccount_name : "${replace(var.resource_prefix, "-", "")}saflowlogs"
  installs_storageaccount_name   = var.installs_storageaccount_name != "default" ? var.installs_storageaccount_name : "${replace(var.resource_prefix, "-", "")}sainstalls"
  vmdiag_storageaccount_name     = var.vmdiag_storageaccount_name != "default" ? var.vmdiag_storageaccount_name : "${replace(var.resource_prefix, "-", "")}savmdiag"
  network_watcher_name           = var.network_watcher_name != "default" ? var.network_watcher_name : "${replace(var.resource_prefix, "-", "_")}_netw_watcher"
}
