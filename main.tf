locals {
  container_app = var.deployment_managed_by_pipeline ? azurerm_container_app.pipeline[0] : azurerm_container_app.this[0]

  effective_environment_id = var.create_environment ? azurerm_container_app_environment.this[0].id : var.environment_id

  effective_environment_name = var.create_environment ? azurerm_container_app_environment.this[0].name : null

  effective_environment_default_domain = try(azurerm_container_app_environment.this[0].default_domain, null)

  effective_environment_static_ip_address = try(azurerm_container_app_environment.this[0].static_ip_address, null)
}

resource "azurerm_container_app_environment" "this" {
  count = var.create_environment ? 1 : 0

  name                = var.environment_name
  location            = var.location
  resource_group_name = var.resource_group_name

  log_analytics_workspace_id     = var.log_analytics_workspace_id
  infrastructure_subnet_id       = var.infrastructure_subnet_id
  internal_load_balancer_enabled = var.internal_load_balancer_enabled
  zone_redundancy_enabled        = var.zone_redundancy_enabled

  dynamic "workload_profile" {
    for_each = var.workload_profiles

    content {
      name                  = workload_profile.value.name
      workload_profile_type = workload_profile.value.workload_profile_type
      minimum_count         = try(workload_profile.value.minimum_count, null)
      maximum_count         = try(workload_profile.value.maximum_count, null)
    }
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [infrastructure_resource_group_name]
  }
}

resource "azurerm_container_app" "this" {
  count                        = var.deployment_managed_by_pipeline ? 0 : 1
  name                         = var.name
  container_app_environment_id = local.effective_environment_id
  resource_group_name          = var.resource_group_name
  revision_mode                = var.revision_mode
  workload_profile_name        = var.workload_profile_name
  tags                         = var.tags

  identity {
    type         = var.identity.type
    identity_ids = var.identity.identity_ids
  }

  dynamic "secret" {
    for_each = nonsensitive(var.secrets)

    content {
      name                = secret.key
      value               = try(secret.value.value, null)
      identity            = try(secret.value.identity, null)
      key_vault_secret_id = try(secret.value.key_vault_secret_id, null)
    }
  }

  dynamic "registry" {
    for_each = var.registries

    content {
      server               = registry.value.server
      identity             = try(registry.value.identity, null)
      username             = try(registry.value.username, null)
      password_secret_name = try(registry.value.password_secret_name, null)
    }
  }

  dynamic "ingress" {
    for_each = var.ingress == null ? [] : [var.ingress]

    content {
      external_enabled           = ingress.value.external_enabled
      target_port                = ingress.value.target_port
      exposed_port               = try(ingress.value.exposed_port, null)
      transport                  = ingress.value.transport
      allow_insecure_connections = ingress.value.allow_insecure_connections

      dynamic "traffic_weight" {
        for_each = ingress.value.traffic_weight

        content {
          percentage      = traffic_weight.value.percentage
          latest_revision = try(traffic_weight.value.latest_revision, null)
          label           = try(traffic_weight.value.label, null)
          revision_suffix = try(traffic_weight.value.revision_suffix, null)
        }
      }
    }
  }

  template {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    dynamic "container" {
      for_each = var.containers

      content {
        name    = container.value.name
        image   = container.value.image
        cpu     = container.value.cpu
        memory  = container.value.memory
        command = try(container.value.command, null)
        args    = try(container.value.args, null)

        dynamic "env" {
          for_each = container.value.env

          content {
            name        = env.value.name
            value       = try(env.value.value, null)
            secret_name = try(env.value.secret_name, null)
          }
        }
      }
    }

    dynamic "http_scale_rule" {
      for_each = var.scale_rules.http

      content {
        name                = http_scale_rule.value.name
        concurrent_requests = http_scale_rule.value.concurrent_requests

        dynamic "authentication" {
          for_each = http_scale_rule.value.authentication

          content {
            secret_name       = authentication.value.secret_name
            trigger_parameter = authentication.value.trigger_parameter
          }
        }
      }
    }

    dynamic "tcp_scale_rule" {
      for_each = var.scale_rules.tcp

      content {
        name                = tcp_scale_rule.value.name
        concurrent_requests = tcp_scale_rule.value.concurrent_requests

        dynamic "authentication" {
          for_each = tcp_scale_rule.value.authentication

          content {
            secret_name       = authentication.value.secret_name
            trigger_parameter = authentication.value.trigger_parameter
          }
        }
      }
    }

    dynamic "azure_queue_scale_rule" {
      for_each = var.scale_rules.azure_queue

      content {
        name         = azure_queue_scale_rule.value.name
        queue_name   = azure_queue_scale_rule.value.queue_name
        queue_length = azure_queue_scale_rule.value.queue_length

        dynamic "authentication" {
          for_each = azure_queue_scale_rule.value.authentication

          content {
            secret_name       = authentication.value.secret_name
            trigger_parameter = authentication.value.trigger_parameter
          }
        }
      }
    }

    dynamic "custom_scale_rule" {
      for_each = var.scale_rules.custom

      content {
        name             = custom_scale_rule.value.name
        custom_rule_type = custom_scale_rule.value.custom_rule_type
        metadata         = custom_scale_rule.value.metadata

        dynamic "authentication" {
          for_each = custom_scale_rule.value.authentication

          content {
            secret_name       = authentication.value.secret_name
            trigger_parameter = authentication.value.trigger_parameter
          }
        }
      }
    }
  }
}

resource "azurerm_container_app" "pipeline" {
  count                        = var.deployment_managed_by_pipeline ? 1 : 0
  name                         = var.name
  container_app_environment_id = local.effective_environment_id
  resource_group_name          = var.resource_group_name
  revision_mode                = var.revision_mode
  workload_profile_name        = var.workload_profile_name
  tags                         = var.tags

  identity {
    type         = var.identity.type
    identity_ids = var.identity.identity_ids
  }

  dynamic "secret" {
    for_each = nonsensitive(var.secrets)

    content {
      name                = secret.key
      value               = try(secret.value.value, null)
      identity            = try(secret.value.identity, null)
      key_vault_secret_id = try(secret.value.key_vault_secret_id, null)
    }
  }

  dynamic "registry" {
    for_each = var.registries

    content {
      server               = registry.value.server
      identity             = try(registry.value.identity, null)
      username             = try(registry.value.username, null)
      password_secret_name = try(registry.value.password_secret_name, null)
    }
  }

  dynamic "ingress" {
    for_each = var.ingress == null ? [] : [var.ingress]

    content {
      external_enabled           = ingress.value.external_enabled
      target_port                = ingress.value.target_port
      exposed_port               = try(ingress.value.exposed_port, null)
      transport                  = ingress.value.transport
      allow_insecure_connections = ingress.value.allow_insecure_connections

      dynamic "traffic_weight" {
        for_each = ingress.value.traffic_weight

        content {
          percentage      = traffic_weight.value.percentage
          latest_revision = try(traffic_weight.value.latest_revision, null)
          label           = try(traffic_weight.value.label, null)
          revision_suffix = try(traffic_weight.value.revision_suffix, null)
        }
      }
    }
  }

  template {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    dynamic "container" {
      for_each = var.containers

      content {
        name    = container.value.name
        image   = container.value.image
        cpu     = container.value.cpu
        memory  = container.value.memory
        command = try(container.value.command, null)
        args    = try(container.value.args, null)

        dynamic "env" {
          for_each = container.value.env

          content {
            name        = env.value.name
            value       = try(env.value.value, null)
            secret_name = try(env.value.secret_name, null)
          }
        }
      }
    }

    dynamic "http_scale_rule" {
      for_each = var.scale_rules.http

      content {
        name                = http_scale_rule.value.name
        concurrent_requests = http_scale_rule.value.concurrent_requests

        dynamic "authentication" {
          for_each = http_scale_rule.value.authentication

          content {
            secret_name       = authentication.value.secret_name
            trigger_parameter = authentication.value.trigger_parameter
          }
        }
      }
    }

    dynamic "tcp_scale_rule" {
      for_each = var.scale_rules.tcp

      content {
        name                = tcp_scale_rule.value.name
        concurrent_requests = tcp_scale_rule.value.concurrent_requests

        dynamic "authentication" {
          for_each = tcp_scale_rule.value.authentication

          content {
            secret_name       = authentication.value.secret_name
            trigger_parameter = authentication.value.trigger_parameter
          }
        }
      }
    }

    dynamic "azure_queue_scale_rule" {
      for_each = var.scale_rules.azure_queue

      content {
        name         = azure_queue_scale_rule.value.name
        queue_name   = azure_queue_scale_rule.value.queue_name
        queue_length = azure_queue_scale_rule.value.queue_length

        dynamic "authentication" {
          for_each = azure_queue_scale_rule.value.authentication

          content {
            secret_name       = authentication.value.secret_name
            trigger_parameter = authentication.value.trigger_parameter
          }
        }
      }
    }

    dynamic "custom_scale_rule" {
      for_each = var.scale_rules.custom

      content {
        name             = custom_scale_rule.value.name
        custom_rule_type = custom_scale_rule.value.custom_rule_type
        metadata         = custom_scale_rule.value.metadata

        dynamic "authentication" {
          for_each = custom_scale_rule.value.authentication

          content {
            secret_name       = authentication.value.secret_name
            trigger_parameter = authentication.value.trigger_parameter
          }
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [template[0].container[0].image]
  }
}

moved {
  from = azurerm_container_app.this
  to   = azurerm_container_app.this[0]
}
