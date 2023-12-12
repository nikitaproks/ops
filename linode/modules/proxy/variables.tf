variable "root_pass" {
  description = "Root password for the Linode instance"
  type        = string
}

variable "shadow_pass" {
  description = "Password for the Shadowsocks proxy"
  type        = string
}
