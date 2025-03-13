locals {
  storage_name_prefix = replace(var.resource_prefix, "-", "")

  # Default names for resources
  default_compute_gallery_name           = "${replace(var.resource_prefix, "-", "_")}_imagegallery_1"
  default_cloudshell_storageaccount_name = length("${local.storage_name_prefix}sacloudshell") <= 24 ? "${local.storage_name_prefix}sacloudshell" : "${var.location_abbreviation}mp${var.app_abbreviation}sacloudshell"
  default_ars_storageaccount_name        = "${replace(var.resource_prefix, "-", "")}saarsvault"
  default_docs_storageaccount_name       = "${replace(var.resource_prefix, "-", "")}docs"
  default_flowlogs_storageaccount_name   = "${replace(var.resource_prefix, "-", "")}saflowlogs"
  default_installs_storageaccount_name   = "${replace(var.resource_prefix, "-", "")}sainstalls"
  default_vmdiag_storageaccount_name     = "${replace(var.resource_prefix, "-", "")}savmdiag"
  default_network_watcher_name           = "${replace(var.resource_prefix, "-", "_")}_netw_watcher"
}
