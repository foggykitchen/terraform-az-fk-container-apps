output "container_app_id" {
  value = module.container_app.id
}

output "container_app_name" {
  value = module.container_app.name
}

output "container_app_fqdn" {
  value = module.container_app.fqdn
}

output "resource_group_name" {
  value = azurerm_resource_group.this.name
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

output "vnet_id" {
  value = module.vnet.vnet_id
}

output "container_apps_subnet_id" {
  value = module.vnet.subnet_ids["container_apps"]
}

output "test_clients_subnet_id" {
  value = module.vnet.subnet_ids["test_clients"]
}

output "private_dns_zone_names" {
  value = [azurerm_private_dns_zone.container_apps_environment.name]
}

output "container_apps_private_dns_record_names" {
  value = keys(azurerm_private_dns_a_record.container_apps_environment)
}

output "bastion_name" {
  value = module.bastion.bastion_name
}

output "bastion_public_ip" {
  value = module.bastion.bastion_public_ip
}

output "test_vm_private_ip" {
  value = module.test_vm.vm_private_ip
}

output "test_vm_id" {
  value = module.test_vm.vm_id
}

output "test_vm_admin_username" {
  value = var.admin_username
}

output "test_vm_ssh_private_key_pem" {
  value     = tls_private_key.test_vm.private_key_pem
  sensitive = true
}
