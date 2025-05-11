terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "2.37.0"
    }
  }
}

resource "linode_domain" "mykytaprokaiev_com" {
  type      = "master"
  domain    = "mykytaprokaiev.com"
  soa_email = var.email
}
