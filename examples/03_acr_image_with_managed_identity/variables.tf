variable "resource_group_name" {
  description = "Resource group name."
  type        = string
  default     = "fk-ca-acr-rg"
}

variable "location" {
  description = "Azure region."
  type        = string
  default     = "westeurope"
}

variable "image_tag" {
  description = "Container image tag."
  type        = string
  default     = "latest"
}

variable "public_source_image" {
  description = "Public source image imported into ACR."
  type        = string
  default     = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
}

variable "import_image" {
  description = "Whether Azure CLI imports the public hello-world image into ACR."
  type        = bool
  default     = true
}

variable "my_public_ip" {
  description = "Optional shared training variable accepted for compatibility with common FoggyKitchen tfvars files. Not used by this example."
  type        = string
  default     = null
}

variable "admin_username" {
  description = "Linux admin username for the private test VM."
  type        = string
  default     = "azureuser"
}

variable "vm_size" {
  description = "Private test VM size."
  type        = string
  default     = "Standard_B1s"
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default = {
    project = "foggykitchen"
    env     = "dev"
  }
}
