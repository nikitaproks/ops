variable "root_pass" {
  description = "Root password for the Linode instance"
  type        = string
}

variable "ssh_public_key" {
  description = "Public SSH key for authentication"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to the private SSH key"
  type        = string
}

variable "mykytaprokaiev_com_domain_id" {
  type = string
}

variable "mykytaprokaiev_com_domain" {
  type = string
}
