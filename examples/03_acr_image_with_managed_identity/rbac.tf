module "rbac" {
  source = "github.com/foggykitchen/terraform-az-fk-rbac"

  scope                = module.acr.acr_id
  principal_id         = azurerm_user_assigned_identity.container_app.principal_id
  role_definition_name = "AcrPull"
}
