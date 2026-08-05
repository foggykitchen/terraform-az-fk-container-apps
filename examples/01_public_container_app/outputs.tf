output "container_app_id" {
  value = module.container_app.id
}

output "container_app_name" {
  value = module.container_app.name
}

output "environment_id" {
  value = module.container_app.environment_id
}

output "environment_default_domain" {
  value = module.container_app.environment_default_domain
}

output "environment_static_ip_address" {
  value = module.container_app.environment_static_ip_address
}

output "latest_revision_fqdn" {
  value = module.container_app.latest_revision_fqdn
}

output "principal_id" {
  value = module.container_app.principal_id
}
