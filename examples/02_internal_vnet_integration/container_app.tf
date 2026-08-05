module "container_app" {
  source = "../../"

  name                = "fk-ca-internal-${random_string.suffix.result}"
  environment_name    = "fk-cae-internal-${random_string.suffix.result}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  log_analytics_workspace_id     = module.log_analytics.id
  infrastructure_subnet_id       = module.vnet.subnet_ids["container_apps"]
  internal_load_balancer_enabled = true
  zone_redundancy_enabled        = false

  containers = [{
    name   = "hello"
    image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
    cpu    = 0.25
    memory = "0.5Gi"
  }]

  min_replicas = 1
  max_replicas = 2

  ingress = {
    external_enabled = true
    target_port      = 80
    transport        = "auto"
    traffic_weight = [{
      percentage      = 100
      latest_revision = true
    }]
  }

  tags = var.tags
}
