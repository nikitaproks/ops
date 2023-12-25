variable "linode_token" {
  description = "Your Linode API Token"
  type        = string
}

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

variable "recaptcha_secret_key" {
  description = "Secret key for google recaptcha"
  type        = string
}

variable "recaptcha_site_key" {
  description = "Site key for google recaptcha"
  type        = string
}

variable "email" {
  description = "Developer email"
  type        = string
}

variable "shadow_pass" {
  description = "Password for the Shadowsocks proxy"
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

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_user" {
  description = "Database user"
  type        = string
}

variable "db_pass" {
  description = "Database password"
  type        = string
}

variable "db_host" {
  description = "Database host"
  type        = string
}

variable "django_secret_key" {
  description = "Django secret key"
  type        = string
}

variable "django_superuser_username" {
  description = "Django superuser username"
  type        = string
}

variable "django_superuser_email" {
  description = "Django superuser email"
  type        = string
}

variable "django_superuser_password" {
  description = "Django superuser password"
  type        = string
}