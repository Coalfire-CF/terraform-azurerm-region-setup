# Offline checks for the secure defaults and input guards. azurerm is mocked,
# so no Azure credentials are needed. Plan runs only.

mock_provider "azurerm" {
  # The diagnostics module inside storage-account has a postcondition that needs categories.
  mock_data "azurerm_monitor_diagnostic_categories" {
    defaults = {
      log_category_groups = ["allLogs"]
      log_category_types  = ["StorageRead"]
      metrics             = ["Transaction"]
    }
  }
}

variables {
  location              = "usgovvirginia"
  location_abbreviation = "usgv"
  app_abbreviation      = "tst"
  resource_prefix       = "test-mp"
  global_tags           = {}
  regional_tags         = {}
  tags                  = { Owner = "test" }
  diag_log_analytics_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/test-law"
}

run "defaults_are_secure" {
  command = plan

  # storage-account v3 returns a null connection string unless shared keys are on,
  # so these prove shared_access_key_enabled = false reached each of the six calls.
  assert {
    condition     = module.ars_sa.primary_connection_string == null
    error_message = "ars_sa must have shared keys off."
  }
  assert {
    condition     = module.docs_sa.primary_connection_string == null
    error_message = "docs_sa must have shared keys off."
  }
  assert {
    condition     = module.flowlogs_sa.primary_connection_string == null
    error_message = "flowlogs_sa must have shared keys off."
  }
  assert {
    condition     = module.installs_sa.primary_connection_string == null
    error_message = "installs_sa must have shared keys off."
  }
  assert {
    condition     = module.vm_diag.primary_connection_string == null
    error_message = "vm_diag must have shared keys off."
  }
  assert {
    condition     = module.cloudshell_sa.primary_connection_string == null
    error_message = "cloudshell_sa must have shared keys off."
  }

  # A root test cannot read resources inside module.*. The assertions below check
  # only the root defaults, not the value each module call receives. They would
  # stay green if one call hardcoded a different value. storage-account v3's own
  # tests assert the resource-level settings (public_network_access = Disabled,
  # min_tls_version = TLS1_2, infrastructure encryption on).
  assert {
    condition     = var.public_network_access == "Disabled"
    error_message = "public_network_access must default to Disabled."
  }
  assert {
    condition     = var.cloudshell_shared_access_key_enabled == false
    error_message = "Cloud Shell shared keys must default off."
  }
  assert {
    condition     = var.enable_customer_managed_key == false
    error_message = "Customer-managed keys must be optional and default off."
  }
  assert {
    condition     = var.storage_replication_type == "GRS"
    error_message = "storage_replication_type must default to GRS."
  }
  assert {
    condition     = var.blob_delete_retention_days == 7 && var.container_delete_retention_days == 7 && var.share_delete_retention_days == 7
    error_message = "Soft delete retention must default to 7 days."
  }
  assert {
    condition     = var.private_endpoint_subnet_id == null
    error_message = "No private endpoint subnet by default."
  }

  assert {
    condition     = azurerm_resource_group.management.tags["Owner"] == "test" && azurerm_resource_group.network.tags["Owner"] == "test" && azurerm_resource_group.application.tags["Owner"] == "test" && azurerm_resource_group.key_vault.tags["Owner"] == "test"
    error_message = "Resource groups must carry the tags input."
  }
  assert {
    condition     = azurerm_shared_image_gallery.marketplaceimages.tags["Owner"] == "test" && azurerm_shared_image_gallery.marketplaceimages.tags["Function"] == "Images"
    error_message = "The gallery must merge module tags with the tags input."
  }
  assert {
    condition     = length(azurerm_storage_blob.file_upload) == 0
    error_message = "No blobs are uploaded by default."
  }
}

run "cmk_requires_key_vault" {
  command = plan

  variables {
    enable_customer_managed_key = true
  }

  expect_failures = [var.core_kv_id]
}

run "public_network_access_rejects_bool_string" {
  command = plan

  variables {
    public_network_access = "true"
  }

  expect_failures = [var.public_network_access]
}

run "replication_type_rejects_unknown" {
  command = plan

  variables {
    storage_replication_type = "XRS"
  }

  expect_failures = [var.storage_replication_type]
}

run "blob_retention_must_exceed_pitr" {
  command = plan

  variables {
    blob_delete_retention_days = 6
  }

  expect_failures = [var.blob_delete_retention_days]
}

run "tags_merge_order" {
  command = plan

  variables {
    regional_tags = { Owner = "regional" }
  }

  assert {
    condition     = azurerm_resource_group.management.tags["Owner"] == "test"
    error_message = "The tags input must win over regional_tags."
  }
}
