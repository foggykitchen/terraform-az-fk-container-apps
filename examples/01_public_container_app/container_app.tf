module "container_app" {
  source = "../../"

  name                = "fk-ca-public-${random_string.suffix.result}"
  environment_name    = "fk-cae-public-${random_string.suffix.result}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  log_analytics_workspace_id = module.log_analytics.id

  containers = [{
    name   = "hello"
    image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
    cpu    = 0.25
    memory = "0.5Gi"
  }]

  min_replicas = 0
  max_replicas = 1

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
