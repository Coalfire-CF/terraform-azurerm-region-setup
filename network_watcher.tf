resource "azurerm_network_watcher" "fr_network_watcher" {
  name                = local.network_watcher_name
  location            = var.location
  resource_group_name = azurerm_resource_group.network.name

  tags = merge({
    Function = "SIEM"
    Plane    = "Management"
  }, var.global_tags, var.regional_tags)
}

