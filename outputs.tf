output "id" {
  value       = azurerm_container_app.this.id
  description = "Container App resource ID."
}

output "name" {
  value       = azurerm_container_app.this.name
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
  value       = azurerm_container_app.this.latest_revision_fqdn
  description = "Latest Container App revision FQDN."
}

output "fqdn" {
  value       = try(azurerm_container_app.this.ingress[0].fqdn, null)
  description = "Container App ingress FQDN."
}

output "latest_revision_name" {
  value       = azurerm_container_app.this.latest_revision_name
  description = "Latest Container App revision name."
}

output "principal_id" {
  value       = try(azurerm_container_app.this.identity[0].principal_id, null)
  description = "Container App managed identity principal ID."
}

output "identity" {
  value       = azurerm_container_app.this.identity
  description = "Container App managed identity attributes."
}
