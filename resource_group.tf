resource "azurerm_resource_group" "network" {
  name     = var.networking_rg_name
  location = var.location

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_resource_group" "application" {
  name     = var.app_rg_name
  location = var.location

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_resource_group" "management" {
  name     = var.mgmt_rg_name
  location = var.location

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_resource_group" "key_vault" {
  name     = var.key_vault_rg_name
  location = var.location

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_resource_group" "additional_resource_groups" {
  for_each = toset(var.additional_resource_groups)
  name     = each.key
  location = var.location

  lifecycle {
    prevent_destroy = true
  }
}