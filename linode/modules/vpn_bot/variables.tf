variable "root_pass" {
  description = "Root password for the Linode instance"
  type        = string
}

variable "telegram_token" {
  description = "Token for the Telegram bot"
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


variable "github_token" {
  description = "Token for accessing github"
  type        = string
}

variable "dockerhub_username" {
  description = "Docker hub username"
  type        = string
}

variable "dockerhub_token" {
  description = "Docker hub token"
  type        = string
}

variable "linode_api_key" {
  description = "API key for linode"
  type        = string
}
