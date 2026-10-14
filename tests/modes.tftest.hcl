mock_provider "azurerm" {}

variables {
  name                = "fk-regression"
  resource_group_name = "fk-regression-rg"
  create_environment  = false
  environment_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/fk-regression-rg/providers/Microsoft.App/managedEnvironments/fk-regression"
  containers          = [{ name = "hello", image = "nginx:1.27-alpine", cpu = 0.25, memory = "0.5Gi" }]
}

run "default_ownership" {
  command = plan
  assert {
    condition     = length(azurerm_container_app.this) == 1 && length(azurerm_container_app.pipeline) == 0
    error_message = "Default mode must preserve Terraform image ownership."
  }
  assert {
    condition     = azurerm_container_app.this[0].template[0].container[0].image == "nginx:1.27-alpine"
    error_message = "The configured image must be preserved in default mode."
  }
}

run "pipeline_ownership" {
  command = plan
  variables { deployment_managed_by_pipeline = true }
  assert {
    condition     = length(azurerm_container_app.this) == 0 && length(azurerm_container_app.pipeline) == 1
    error_message = "Pipeline mode must create exactly one application."
  }
  assert {
    condition     = azurerm_container_app.pipeline[0].template[0].container[0].cpu == 0.25
    error_message = "Pipeline mode must preserve Terraform-managed runtime settings."
  }
}

run "reject_multiple_containers" {
  command = plan
  variables {
    deployment_managed_by_pipeline = true
    containers = [
      { name = "hello", image = "nginx:1.27-alpine", cpu = 0.25, memory = "0.5Gi" },
      { name = "sidecar", image = "nginx:1.27-alpine", cpu = 0.25, memory = "0.5Gi" }
    ]
  }
  expect_failures = [var.deployment_managed_by_pipeline]
}
