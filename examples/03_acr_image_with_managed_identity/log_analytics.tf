module "log_analytics" {
  source = "github.com/foggykitchen/terraform-az-fk-log-analytics"

  name                = "fk-ca-acr-law-${random_string.suffix.result}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  retention_in_days = 30
  tags              = var.tags
}
