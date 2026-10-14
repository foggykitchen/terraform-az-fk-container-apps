variable "name" {
  description = "Container App name."
  type        = string
}

variable "environment_name" {
  description = "Container Apps Environment name. Required when create_environment is true."
  type        = string
  default     = null
}

variable "location" {
  description = "Azure region. Required when create_environment is true."
  type        = string
  default     = null
}

variable "resource_group_name" {
  description = "Resource group name."
  type        = string
}

variable "create_environment" {
  description = "Whether the module creates a new Container Apps Environment."
  type        = bool
  default     = true
}

variable "environment_id" {
  description = "Existing Container Apps Environment resource ID."
  type        = string
  default     = null
}

variable "log_analytics_workspace_id" {
  description = "Existing Log Analytics Workspace resource ID for environment logs."
  type        = string
  default     = null
}

variable "infrastructure_subnet_id" {
  description = "Subnet ID used by the Container Apps Environment infrastructure."
  type        = string
  default     = null
}

variable "internal_load_balancer_enabled" {
  description = "Whether the environment uses internal load balancing."
  type        = bool
  default     = null
}

variable "zone_redundancy_enabled" {
  description = "Whether zone redundancy is enabled for the environment."
  type        = bool
  default     = null
}

variable "workload_profiles" {
  description = "Optional workload profiles for the Container Apps Environment."
  type = list(object({
    name                  = string
    workload_profile_type = string
    minimum_count         = optional(number)
    maximum_count         = optional(number)
  }))
  default = []

  validation {
    condition = alltrue([
      for profile in var.workload_profiles :
      contains(["Consumption", "Consumption-GPU-NC24-A100", "Consumption-GPU-NC8as-T4", "D4", "D8", "D16", "D32", "E4", "E8", "E16", "E32", "NC24-A100", "NC48-A100", "NC96-A100"], profile.workload_profile_type)
    ])
    error_message = "workload_profile_type must be a supported Container Apps workload profile type."
  }

  validation {
    condition = length([
      for profile in var.workload_profiles : profile
      if profile.workload_profile_type == "Consumption" && profile.name != "Consumption"
    ]) == 0
    error_message = "A Consumption workload profile must be named Consumption."
  }
}

variable "revision_mode" {
  description = "Container App revision mode."
  type        = string
  default     = "Single"

  validation {
    condition     = contains(["Single", "Multiple"], var.revision_mode)
    error_message = "revision_mode must be Single or Multiple."
  }
}

variable "containers" {
  description = "Container definitions for the Container App."
  type = list(object({
    name    = string
    image   = string
    cpu     = number
    memory  = string
    command = optional(list(string))
    args    = optional(list(string))
    env = optional(list(object({
      name        = string
      value       = optional(string)
      secret_name = optional(string)
    })), [])
  }))

  validation {
    condition     = length(var.containers) > 0
    error_message = "At least one container is required."
  }
}

variable "min_replicas" {
  description = "Minimum Container App replicas."
  type        = number
  default     = 0
}

variable "max_replicas" {
  description = "Maximum Container App replicas."
  type        = number
  default     = 1

  validation {
    condition     = var.max_replicas >= 1
    error_message = "max_replicas must be at least 1."
  }
}

variable "scale_rules" {
  description = "KEDA scale rules for the Container App."
  type = object({
    http = optional(list(object({
      name                = string
      concurrent_requests = string
      authentication = optional(list(object({
        secret_name       = string
        trigger_parameter = string
      })), [])
    })), [])
    tcp = optional(list(object({
      name                = string
      concurrent_requests = string
      authentication = optional(list(object({
        secret_name       = string
        trigger_parameter = string
      })), [])
    })), [])
    azure_queue = optional(list(object({
      name         = string
      queue_name   = string
      queue_length = number
      authentication = list(object({
        secret_name       = string
        trigger_parameter = string
      }))
    })), [])
    custom = optional(list(object({
      name             = string
      custom_rule_type = string
      metadata         = map(string)
      authentication = optional(list(object({
        secret_name       = string
        trigger_parameter = string
      })), [])
    })), [])
  })
  default = {}
}

variable "ingress" {
  description = "Ingress configuration for the Container App."
  type = object({
    external_enabled           = optional(bool, false)
    target_port                = number
    exposed_port               = optional(number)
    transport                  = optional(string, "auto")
    allow_insecure_connections = optional(bool, false)
    traffic_weight = optional(list(object({
      percentage      = number
      latest_revision = optional(bool, true)
      label           = optional(string)
      revision_suffix = optional(string)
    })), [{ percentage = 100, latest_revision = true }])
  })
  default = null

  validation {
    condition     = var.ingress == null || contains(["auto", "http", "http2", "tcp"], var.ingress.transport)
    error_message = "ingress.transport must be auto, http, http2, or tcp."
  }
}

variable "registries" {
  description = "Container registry authentication blocks."
  type = list(object({
    server               = string
    identity             = optional(string)
    username             = optional(string)
    password_secret_name = optional(string)
  }))
  default = []
}

variable "secrets" {
  description = "Container App secrets."
  type = map(object({
    value               = optional(string)
    identity            = optional(string)
    key_vault_secret_id = optional(string)
  }))
  default   = {}
  sensitive = true
}

variable "identity" {
  description = "Managed identity assigned to the Container App."
  type = object({
    type         = string
    identity_ids = optional(list(string), [])
  })
  default = {
    type = "SystemAssigned"
  }

  validation {
    condition     = contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.identity.type)
    error_message = "identity.type must be SystemAssigned, UserAssigned, or SystemAssigned, UserAssigned."
  }
}

variable "workload_profile_name" {
  description = "Workload profile name used by the Container App."
  type        = string
  default     = "Consumption"
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}

variable "deployment_managed_by_pipeline" {
  description = "Whether the deployment pipeline owns the single container image after initial creation. Choose before deployment; changing mode requires a state move."
  type        = bool
  default     = false
  validation {
    condition     = !var.deployment_managed_by_pipeline || length(var.containers) == 1
    error_message = "Pipeline-managed deployments require exactly one container."
  }
}
