module "acr" {
  source = "github.com/foggykitchen/terraform-az-fk-acr"

  acr_name            = "fkcacr${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  sku                 = "Basic"
  admin_enabled       = false

  tags = var.tags
}

resource "terraform_data" "acr_import_hello_world" {
  count = var.import_image ? 1 : 0

  triggers_replace = {
    registry = module.acr.acr_name
    image    = "foggykitchen-hello-world:${var.image_tag}"
    source   = var.public_source_image
  }

  depends_on = [module.acr]

  provisioner "local-exec" {
    command = "az acr import --name ${module.acr.acr_name} --source ${var.public_source_image} --image foggykitchen-hello-world:${var.image_tag} --force"
  }
}
