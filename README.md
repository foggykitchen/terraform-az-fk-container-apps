# terraform-az-fk-container-apps

This repository contains a reusable Terraform / OpenTofu module and progressive examples for deploying Azure Container Apps as the Azure "bring your own container image" runtime in the FoggyKitchen catalog.

It is part of the [FoggyKitchen.com training ecosystem](https://foggykitchen.com/courses-2/) and is designed to compose cleanly with reusable Azure infrastructure modules such as `terraform-az-fk-log-analytics`, `terraform-az-fk-vnet`, `terraform-az-fk-acr`, `terraform-az-fk-rbac`, `terraform-az-fk-bastion`, and `terraform-az-fk-compute`.

Support expectations are documented in [SUPPORT.md](SUPPORT.md).

---

## Purpose

The goal of this module is to provide a clean, composable, and educational reference implementation for Azure Container Apps:

- Focused on Container Apps Environment and Container App lifecycle
- Suitable for public containers, internal VNet-integrated apps, and private ACR image pulls
- Designed for hands-on learning, module composition, and multicloud comparisons with OCI Container Instances

This is not an Azure Functions module. Azure Functions is a code-first service built on App Service concepts, with storage accounts, function runtimes, zip deployments, and native trigger bindings. Azure Container Apps is the closer match for the OCI Container Instance pattern because it runs container images directly and scales through Container Apps/KEDA semantics.

The Azure Functions module belongs separately as `terraform-az-fk-function`.

---

## What the module does

The module creates:

- Azure Container Apps Environment, unless `create_environment = false`
- Azure Container App
- Optional workload profiles on the environment; Consumption is available by default
- Optional VNet integration through `infrastructure_subnet_id`
- Optional internal load balancer mode for the environment
- Optional Container App ingress
- Optional registry, secret, managed identity, and KEDA scale rule blocks

The module intentionally does not create:

- Log Analytics Workspaces
- VNets or delegated subnets
- Azure Container Registries
- RBAC role assignments
- Bastion hosts or test VMs
- Azure Public IP resources
- Azure Functions, Function Apps, App Service Plans, or Storage Accounts
- Application source builds or CI/CD pipelines

Each of those concerns belongs in its own dedicated module or workflow layer.

For public Container Apps, Azure Container Apps external ingress exposes a managed
public endpoint and FQDN from the Container Apps Environment. It is not the OCI
pattern where a public IP is composed with a separate load balancer resource, so
`terraform-az-fk-public-ip` is not used in the minimal public example.

---

## Provider Notes

The module contract follows the current AzureRM provider resource schemas for:

- `azurerm_container_app_environment`
- `azurerm_container_app`

One important documentation detail: the rendered Terraform Registry text for `azurerm_container_app.registry.identity` emphasizes user-assigned identities, while the current AzureRM provider schema describes the field as the ID of the system or user managed identity used to pull from the registry. This module keeps `registries[*].identity` as a plain string. The ACR example uses a user-assigned identity so the `AcrPull` role assignment exists before the first Container App revision pulls the image.

---

## Repository Structure

```bash
terraform-az-fk-container-apps/
├── examples/
│   ├── 01_public_container_app/
│   ├── 02_internal_vnet_integration/
│   ├── 03_acr_image_with_managed_identity/
│   └── README.md
├── main.tf
├── inputs.tf
├── outputs.tf
├── versions.tf
├── SUPPORT.md
├── LICENSE
└── README.md
```

All examples demonstrate incremental Azure Container Apps patterns, starting from a public container image and progressing toward internal networking and private ACR image pulls with managed identity.

---

## Example Usage

### Public container app

```hcl
module "container_app" {
  source = "git::https://github.com/foggykitchen/terraform-az-fk-container-apps.git?ref=v0.1.0"

  name                = "fk-ca-public"
  environment_name    = "fk-cae-public"
  location            = "westeurope"
  resource_group_name = "fk-container-apps-rg"

  log_analytics_workspace_id = module.log_analytics.id

  containers = [{
    name   = "hello"
    image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
    cpu    = 0.25
    memory = "0.5Gi"
  }]

  ingress = {
    external_enabled = true
    target_port      = 80
    traffic_weight = [{
      percentage      = 100
      latest_revision = true
    }]
  }

  tags = {
    project = "foggykitchen"
    env     = "dev"
  }
}
```

### Existing environment

```hcl
module "container_app" {
  source = "git::https://github.com/foggykitchen/terraform-az-fk-container-apps.git?ref=v0.1.0"

  name                = "fk-ca-existing-env"
  resource_group_name = "fk-container-apps-rg"

  create_environment = false
  environment_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/fk-rg/providers/Microsoft.App/managedEnvironments/fk-cae"

  containers = [{
    name   = "hello"
    image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
    cpu    = 0.25
    memory = "0.5Gi"
  }]
}
```

### ACR pull with managed identity

```hcl
resource "azurerm_user_assigned_identity" "container_app" {
  name                = "fk-ca-acr-identity"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
}

module "rbac" {
  source = "github.com/foggykitchen/terraform-az-fk-rbac"

  scope                = module.acr.acr_id
  principal_id         = azurerm_user_assigned_identity.container_app.principal_id
  role_definition_name = "AcrPull"
}

module "container_app" {
  source = "git::https://github.com/foggykitchen/terraform-az-fk-container-apps.git?ref=v0.1.0"

  name                = "fk-ca-acr"
  environment_name    = "fk-cae-acr"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  log_analytics_workspace_id = module.log_analytics.id
  infrastructure_subnet_id   = module.vnet.subnet_ids["container_apps"]

  registries = [{
    server   = module.acr.acr_login_server
    identity = azurerm_user_assigned_identity.container_app.id
  }]

  identity = {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.container_app.id]
  }

  containers = [{
    name   = "hello"
    image  = "${module.acr.acr_login_server}/foggykitchen-hello-world:latest"
    cpu    = 0.25
    memory = "0.5Gi"
  }]
  depends_on = [module.rbac]
}
```

---

## Module Inputs

### Core inputs

| Variable | Type | Required | Description |
|----------|------|----------|-------------|
| `name` | `string` | yes | Container App name |
| `resource_group_name` | `string` | yes | Resource group name |
| `environment_name` | `string` | when creating | Container Apps Environment name |
| `location` | `string` | when creating | Azure region |
| `create_environment` | `bool` | no | Whether to create a new environment |
| `environment_id` | `string` | when attaching | Existing environment resource ID |
| `log_analytics_workspace_id` | `string` | no | Existing Log Analytics Workspace resource ID |
| `infrastructure_subnet_id` | `string` | no | Subnet ID for environment infrastructure |
| `internal_load_balancer_enabled` | `bool` | no | Whether the environment uses internal load balancing |
| `zone_redundancy_enabled` | `bool` | no | Whether zone redundancy is enabled |
| `workload_profiles` | `list(object)` | no | Optional environment workload profiles |
| `revision_mode` | `string` | no | Container App revision mode |
| `containers` | `list(object)` | yes | Container definitions |
| `min_replicas` | `number` | no | Minimum replicas |
| `max_replicas` | `number` | no | Maximum replicas |
| `scale_rules` | `object` | no | KEDA scale rules |
| `ingress` | `object` | no | Container App ingress |
| `registries` | `list(object)` | no | Registry authentication blocks |
| `secrets` | `map(object)` | no | Container App secrets |
| `identity` | `object` | no | Managed identity assigned to the Container App |
| `tags` | `map(string)` | no | Common tags |

### `containers` object schema

```hcl
containers = list(object({
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
```

### `registries` object schema

```hcl
registries = list(object({
  server               = string
  identity             = optional(string)
  username             = optional(string)
  password_secret_name = optional(string)
}))
```

### `secrets` object schema

```hcl
secrets = map(object({
  value               = optional(string)
  identity            = optional(string)
  key_vault_secret_id = optional(string)
}))
```

---

## Module Outputs

| Output | Description |
|--------|-------------|
| `id` | Container App resource ID |
| `name` | Container App name |
| `environment_id` | Container Apps Environment resource ID |
| `environment_name` | Created Container Apps Environment name |
| `environment_default_domain` | Created Container Apps Environment default domain |
| `environment_static_ip_address` | Created Container Apps Environment static IP address |
| `latest_revision_fqdn` | Latest Container App revision FQDN |
| `latest_revision_name` | Latest Container App revision name |
| `principal_id` | Container App managed identity principal ID |
| `identity` | Container App managed identity attributes |

---

## Examples

See [examples/README.md](examples/README.md) for the progressive lab sequence.

---

## License

Licensed under the Universal Permissive License (UPL), Version 1.0.
See [LICENSE](LICENSE) for details.

---

© 2026 [FoggyKitchen.com](https://foggykitchen.com) - Cloud. Code. Clarity.
