terraform {
  required_version = ">= 1.16.6, < 2.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.10"
    }
  }
}

provider "azurerm" {
  features {}
  environment                     = "usgovernment"
  resource_provider_registrations = "none"
  resource_providers_to_register  = ["Microsoft.Compute", "Microsoft.Insights", "Microsoft.Network", "Microsoft.Storage"]
  storage_use_azuread             = true
}

module "region_setup" {
  source = "../.."

  location              = var.location
  location_abbreviation = var.location_abbreviation
  app_abbreviation      = var.app_abbreviation
  resource_prefix       = var.resource_prefix
  global_tags           = var.global_tags
  regional_tags         = var.regional_tags
  tags                  = var.tags
  diag_log_analytics_id = var.diag_log_analytics_id

  private_endpoint_subnet_id = var.private_endpoint_subnet_id
  blob_private_dns_zone_id   = var.blob_private_dns_zone_id
  file_private_dns_zone_id   = var.file_private_dns_zone_id
}
