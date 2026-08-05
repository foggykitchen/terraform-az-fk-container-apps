resource "azurerm_user_assigned_identity" "container_app" {
  name                = "fk-ca-acr-identity-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  tags = var.tags
}
