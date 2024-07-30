variable "resource_group_name" {
  description = "The name of the Azure Resource Group"
  type        = string
  default     = "fastify-hello-world"
}

variable "admin_username" {
  description = "The username for the Virtual Machine"
  type        = string
}

variable "admin_ssh_key" {
  description = "The path to the SSH public key used to authenticate the Virtual Machine"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "admin_ssh_allowed_ips" {
  description = "The list of IP addresses allowed to connect to the Virtual Machine"
  type        = list(string)
  default     = []
}

variable "source_image_name" {
  description = "The name of the image used to create the Virtual Machine"
  type        = string
}
