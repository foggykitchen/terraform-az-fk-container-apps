module "vnet" {
  source = "github.com/foggykitchen/terraform-az-fk-vnet"

  name                = "fk-ca-internal-vnet-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  address_space       = ["10.42.0.0/16"]

  subnets = {
    container_apps = {
      address_prefixes = ["10.42.0.0/23"]
      delegations = [{
        name = "container-apps-environment"
        service_delegation = {
          name    = "Microsoft.App/environments"
          actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
        }
      }]
    }
    test_clients = {
      address_prefixes = ["10.42.10.0/24"]
    }
    AzureBastionSubnet = {
      address_prefixes = ["10.42.100.0/26"]
    }
  }

  tags = var.tags
}
