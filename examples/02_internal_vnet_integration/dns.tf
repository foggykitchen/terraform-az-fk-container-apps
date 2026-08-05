locals {
  container_apps_private_dns_records = toset(["@", "*", "*.internal"])
}

resource "azurerm_private_dns_zone" "container_apps_environment" {
  name                = module.container_app.environment_default_domain
  resource_group_name = azurerm_resource_group.this.name

  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "container_apps_environment" {
  name                  = "container-apps"
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.container_apps_environment.name
  virtual_network_id    = module.vnet.vnet_id
  registration_enabled  = false

  tags = var.tags
}

resource "azurerm_private_dns_a_record" "container_apps_environment" {
  for_each = local.container_apps_private_dns_records

  name                = each.value
  zone_name           = azurerm_private_dns_zone.container_apps_environment.name
  resource_group_name = azurerm_resource_group.this.name
  ttl                 = 300
  records             = [module.container_app.environment_static_ip_address]

  depends_on = [azurerm_private_dns_zone_virtual_network_link.container_apps_environment]
}
