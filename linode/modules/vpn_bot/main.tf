terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "2.37.0"
    }
  }
}



# resource "linode_instance" "vpn_bot" {
#   label     = "vpn-bot"
#   image     = "linode/ubuntu20.04"
#   region    = "eu-central"
#   type      = "g6-nanode-1"
#   root_pass = var.root_pass

#   authorized_keys = [
#     var.ssh_public_key
#   ]
# }
