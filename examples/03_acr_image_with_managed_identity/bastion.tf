module "bastion" {
  source = "github.com/foggykitchen/terraform-az-fk-bastion"

  name                = "fk-ca-acr-bastion-${random_string.suffix.result}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  bastion_subnet_id   = module.vnet.subnet_ids["AzureBastionSubnet"]

  tags = var.tags
}
