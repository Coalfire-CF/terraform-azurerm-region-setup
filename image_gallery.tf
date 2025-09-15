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
  hyper_v_generation  = each.value.hyper_v_generation
  #architecture = 
  
  identifier {
    publisher = each.value.identifier_publisher
    offer     = each.value.identifier_offer
    sku       = each.value.identifier_sku
  }

  dynamic "purchase_plan" {
    for_each = lookup(each.value, "purchase_plan_name", null) != null ? [1] : []
    content {
      name      = each.value.purchase_plan_name
      publisher = each.value.purchase_plan_publisher
      product   = each.value.purchase_plan_product
    }
  }

  }

  # Add purchase_plan block for marketplace images
  # dynamic "purchase_plan" {
  #   for_each = try(each.value.purchase_plan, null) != null ? [each.value.purchase_plan] : []
  #   content {
  #     name      = purchase_plan.value.name
  #     publisher = purchase_plan.value.publisher
  #     product   = purchase_plan.value.product
  #   }
  # }
 # }

resource "azurerm_shared_image_version" "versions" {
  for_each = {
    for def in var.vm_image_definitions : def.name => def
    if def.managed_image_id != null
  }

  name                = "1.0.0" # You can make this dynamic if needed
  gallery_name        = azurerm_shared_image_gallery.marketplaceimages.name
  image_name          = azurerm_shared_image.images[each.key].name
  resource_group_name = azurerm_resource_group.management.name
  location            = var.location

  # Region replication (can be just one region or multiple)
  target_region {
    name                   = var.location
    regional_replica_count = var.regional_replica_count
    storage_account_type   = var.storage_account_type
  }

  # Example: publishing from a managed image ID
  managed_image_id = each.value.managed_image_id

  tags = merge({
    Function = "Images"
    Plane    = "Management"
  }, var.global_tags, var.regional_tags)
}