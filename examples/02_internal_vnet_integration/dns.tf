locals {
  container_apps_private_dns_records = toset(["@", "*", "*.internal"])
}

module "private_dns" {
  source = "github.com/foggykitchen/terraform-az-fk-private-dns"

  resource_group_name = azurerm_resource_group.this.name
  private_dns_zones = {
    container_apps = {
      name = module.container_app.environment_default_domain
    }
  }

  vnet_links = {
    container_apps = {
      vnet_id              = module.vnet.vnet_id
      registration_enabled = false
    }
  }

  private_dns_a_records = {
    for record_name in local.container_apps_private_dns_records : record_name => {
      zone_key = "container_apps"
      name     = record_name
      ttl      = 300
      records  = [module.container_app.environment_static_ip_address]
    }
  }

  tags = var.tags
}
