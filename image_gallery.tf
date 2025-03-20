resource "azurerm_shared_image_gallery" "marketplaceimages" {
  name                = local.compute_gallery_name
  resource_group_name = azurerm_resource_group.management.name
  location            = var.location
  description         = "Images for FedRAMP Environment"

  tags = merge({
    Function = "Images"
    Plane    = "Management"
  }, var.global_tags, var.regional_tags)
}

resource "azurerm_shared_image" "images" {
  depends_on          = [azurerm_shared_image_gallery.marketplaceimages]
  for_each            = { for def in var.vm_image_definitions : def.name => def }
  name                = each.value.name
  gallery_name        = azurerm_shared_image_gallery.marketplaceimages.name
  resource_group_name = azurerm_resource_group.management.name
  location            = var.location
  os_type             = each.value.os_type
  identifier {
    publisher = each.value.identifier_publisher
    offer     = each.value.identifier_offer
    sku       = each.value.identifier_sku
  }
}
