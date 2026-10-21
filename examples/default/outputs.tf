output "management_rg_name" {
  description = "Name of the management resource group."
  value       = module.region_setup.management_rg_name
}

output "storage_account_install_id" {
  description = "Resource ID of the installs storage account."
  value       = module.region_setup.storage_account_install_id
}
