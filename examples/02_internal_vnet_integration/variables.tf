variable "resource_group_name" {
  description = "Resource group name."
  type        = string
  default     = "fk-ca-internal-rg"
}

variable "location" {
  description = "Azure region."
  type        = string
  default     = "westeurope"
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
