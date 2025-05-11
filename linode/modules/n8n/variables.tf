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


variable "mount_dir" {
  type = string
}

variable "postgres_database" {
  type = string
}

variable "postgres_host" {
  type = string
}

variable "postgres_port" {
  type = string
}

variable "postgres_user" {
  type = string
}

variable "postgres_password" {
  type = string
}

variable "postgres_schema" {
  type = string
}
