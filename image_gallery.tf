resource "azurerm_shared_image_gallery" "packerimages" {
  name                = "${replace(var.resource_prefix, "-", "_")}_imagegallery_1"
  resource_group_name = azurerm_resource_group.management.name
  location            = var.location
  description         = "Packer Images for FedRAMP Environment"

  tags = merge({
    Function = "Images"
    Plane    = "Management"
  }, var.global_tags, var.regional_tags)
}

resource "azurerm_shared_image" "windows2019" {
  name                = "windows-2019-golden"
  gallery_name        = azurerm_shared_image_gallery.packerimages.name
  resource_group_name = azurerm_resource_group.management.name
  location            = var.location
  os_type             = "Windows"

  identifier {
    publisher = "Coalfire"
    offer     = "WindowsServer"
    sku       = "2019-Golden"
  }
}

resource "azurerm_shared_image" "windows2019ad" {
  name                = "windows-2019-ad"
  gallery_name        = azurerm_shared_image_gallery.packerimages.name
  resource_group_name = azurerm_resource_group.management.name
  location            = var.location
  os_type             = "Windows"

  identifier {
    publisher = "Coalfire"
    offer     = "WindowsServer"
    sku       = "2019-AD"
  }
}

resource "azurerm_shared_image" "windows2019ca" {
  name                = "windows-2019-ca"
  gallery_name        = azurerm_shared_image_gallery.packerimages.name
  resource_group_name = azurerm_resource_group.management.name
  location            = var.location
  os_type             = "Windows"

  identifier {
    publisher = "Coalfire"
    offer     = "WindowsServer"
    sku       = "2019-CA"
  }
}

resource "azurerm_shared_image" "rhel8-golden" {
  name                = "rhel8-golden-fips"
  gallery_name        = azurerm_shared_image_gallery.packerimages.name
  resource_group_name = azurerm_resource_group.management.name
  location            = var.location
  os_type             = "Linux"

  identifier {
    publisher = "Coalfire"
    offer     = "Rhel"
    sku       = "8.4-FIPS"
  }
}

## monitoring - image gall doesn't support diag settings
