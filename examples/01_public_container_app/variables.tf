variable "resource_group_name" {
  description = "Resource group name."
  type        = string
  default     = "fk-ca-public-rg"
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

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default = {
    project = "foggykitchen"
    env     = "dev"
  }
}
