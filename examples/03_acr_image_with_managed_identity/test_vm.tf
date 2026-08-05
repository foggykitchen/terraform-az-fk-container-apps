module "test_vm" {
  source = "github.com/foggykitchen/terraform-az-fk-compute"

  name                = "fk-ca-acr-test-vm-${random_string.suffix.result}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  deployment_mode = "vm"
  subnet_id       = module.vnet.subnet_ids["test_clients"]

  admin_username = var.admin_username
  ssh_public_key = tls_private_key.test_vm.public_key_openssh
  vm_size        = var.vm_size

  tags = var.tags
}
