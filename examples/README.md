# Azure Container Apps with Terraform/OpenTofu - Training Examples

This directory contains progressive examples used with the **terraform-az-fk-container-apps** module.
The examples are designed as incremental building blocks for Azure container workload architectures.

These examples are part of the [FoggyKitchen.com training ecosystem](https://foggykitchen.com/courses-2/) and are meant to be applied independently for learning and experimentation.

---

## Example Overview

| Example | Title | Key Topics |
|:-------:|:------|:-----------|
| 01 | **Public Container App** | Container Apps Environment, Log Analytics, public image, external ingress |
| 02 | **Internal VNet Integration** | delegated subnet, internal load balancer, internal ingress, Bastion test path |
| 03 | **ACR Image With Managed Identity** | same private path as 02, ACR, system-assigned identity, AcrPull RBAC, private image pull |

---

## How to Use

Each example directory contains:

- Terraform/OpenTofu configuration (`.tf`)
- A focused `README.md` explaining the goal of the example
- A `terraform.tfvars.example` file with placeholder values

To run an example:

```bash
cd examples/01_public_container_app
cp terraform.tfvars.example terraform.tfvars
tofu init
tofu plan
tofu apply
```

The recommended learning path is sequential:

```text
01 -> 02 -> 03
```

---

## Design Principles

- One example = one architectural goal
- Log Analytics, VNet, ACR, and RBAC stay in their dedicated FoggyKitchen modules
- Public Container Apps use ACA-managed external ingress, not a separate Azure Public IP resource
- Container Apps internal ingress replaces the separate load balancer composition used in the OCI private container instance example
- Bastion and private test VMs are composed in examples where a private endpoint must be exercised
- Examples avoid hardcoded credentials and ACR admin-user pulls
- OpenTofu is the primary runtime used in the examples

---

## Related Resources

- [FoggyKitchen Azure Container Apps Module](../)
- [FoggyKitchen Azure Log Analytics Module](https://github.com/foggykitchen/terraform-az-fk-log-analytics)
- [FoggyKitchen Azure VNet Module](https://github.com/foggykitchen/terraform-az-fk-vnet)
- [FoggyKitchen Azure Container Registry Module](https://github.com/foggykitchen/terraform-az-fk-acr)
- [FoggyKitchen Azure RBAC Module](https://github.com/foggykitchen/terraform-az-fk-rbac)
- [FoggyKitchen OCI Container Instance Module](https://github.com/foggykitchen/terraform-oci-fk-container-instance)

---

## License

Licensed under the Universal Permissive License (UPL), Version 1.0.
See [LICENSE](../LICENSE) for details.

---

© 2026 [FoggyKitchen.com](https://foggykitchen.com) - Cloud. Code. Clarity.
