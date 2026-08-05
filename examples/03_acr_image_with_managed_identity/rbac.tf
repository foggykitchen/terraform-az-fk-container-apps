module "rbac" {
  source = "github.com/foggykitchen/terraform-az-fk-rbac"

  scope                = module.acr.acr_id
  principal_id         = module.identity.principal_id
  role_definition_name = "AcrPull"
}
