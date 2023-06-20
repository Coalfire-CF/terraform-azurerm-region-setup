output "rhel8_id" {
  value = azurerm_shared_image.rhel8-golden.id
}

output "windows_golden_id" {
  value = azurerm_shared_image.windows2019.id
}

output "windows_ad_id" {
  value = azurerm_shared_image.windows2019ad.id
}

output "windows_ca_id" {
  value = azurerm_shared_image.windows2019ca.id
}

output "storage_account_flowlogs_id" {
  value = module.flowlogs_sa.id
}

output "storage_account_flowlogs_name" {
  value = module.flowlogs_sa.name
}

output "storage_account_install_id" {
  value = module.installs_sa.id
}

output "storage_account_install_name" {
  value = module.installs_sa.name
}

output "storage_account_docs_id" {
  value = module.docs_sa.id
}

output "storage_account_docs_name" {
  value = module.docs_sa.name
}

output "storage_account_vmdiag_id" {
  value = module.vm_diag.id
}

output "storage_account_vmdiag_name" {
  value = module.vm_diag.name
}

output "storage_account_vm_diag_sas" {
  sensitive = true
  value     = data.azurerm_storage_account_sas.vm_diag_sas.sas
}

output "vmdiag_endpoint" {
  value = module.vm_diag.primary_blob_endpoint
}

output "shellscripts_container_id" {
  #value = azurerm_storage_container.shellscripts_container.id
  value = module.installs_sa.container_ids["shellscripts"]

}

output "installs_container_id" {
  #value = azurerm_storage_container.installfile_container.id
  value = module.installs_sa.container_ids["install-files"]

}

output "installs_container_name" {
  #value = azurerm_storage_container.installfile_container.name
  value = module.installs_sa.container_names["install-filess"]

}

output "storage_account_ars_id" {
  value = module.ars_sa.id
}

output "storage_account_ars_name" {
  value = module.ars_sa.name
}

output "management_rg_name" {
  value = azurerm_resource_group.management.name
}

output "network_rg_name" {
  value = azurerm_resource_group.network.name
}

output "key_vault_rg_name" {
  value = azurerm_resource_group.key_vault.name
}

output "key_vault_rg_id" {
  value = azurerm_resource_group.key_vault.id
}

output "application_rg_name" {
  value = azurerm_resource_group.application.name
}

output "network_watcher_name" {
  value = azurerm_network_watcher.fr_network_watcher.name
}

output "additional_resource_groups" {
  value = { for group in azurerm_resource_group.additional_resource_groups : group.name => group.id }
}
