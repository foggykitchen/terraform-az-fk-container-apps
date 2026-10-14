output "id" {
  value       = local.container_app.id
  description = "Container App resource ID."
}

output "name" {
  value       = local.container_app.name
  description = "Container App name."
}

output "environment_id" {
  value       = local.effective_environment_id
  description = "Container Apps Environment resource ID."
}

output "environment_name" {
  value       = local.effective_environment_name
  description = "Created Container Apps Environment name."
}

output "environment_default_domain" {
  value       = local.effective_environment_default_domain
  description = "Created Container Apps Environment default domain."
}

output "environment_static_ip_address" {
  value       = local.effective_environment_static_ip_address
  description = "Created Container Apps Environment static IP address."
}

output "latest_revision_fqdn" {
  value       = local.container_app.latest_revision_fqdn
  description = "Latest Container App revision FQDN."
}

output "fqdn" {
  value       = try(local.container_app.ingress[0].fqdn, null)
  description = "Container App ingress FQDN."
}

output "latest_revision_name" {
  value       = local.container_app.latest_revision_name
  description = "Latest Container App revision name."
}

output "principal_id" {
  value       = try(local.container_app.identity[0].principal_id, null)
  description = "Container App managed identity principal ID."
}

output "identity" {
  value       = local.container_app.identity
  description = "Container App managed identity attributes."
}
