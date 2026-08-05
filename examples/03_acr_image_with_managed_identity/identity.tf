module "identity" {
  source = "github.com/foggykitchen/terraform-az-fk-managed-identity"

  name                = "fk-ca-acr-identity-${random_string.suffix.result}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = var.tags
}
