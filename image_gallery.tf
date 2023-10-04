resource "azurerm_shared_image_gallery" "marketplaceimages" {
  name                = "${replace(var.resource_prefix, "-", "_")}_imagegallery_1"
  resource_group_name = azurerm_resource_group.management.name
  location            = var.location
  description         = "Images for FedRAMP Environment"

  tags = merge({
    Function = "Images"
    Plane    = "Management"
  }, var.global_tags, var.regional_tags)
}

