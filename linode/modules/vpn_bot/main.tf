terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "2.31.1"
    }
  }
}


resource "linode_stackscript" "vpn_bot_stackscript" {
  label       = "vpn-bot-stackscript"
  description = "Installs and starts vpn bot"
  script      = file("./stackscripts/vpn_bot.sh")
  images      = ["linode/ubuntu20.04", "linode/ubuntu22.04"]
  rev_note    = "initial version"

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

#   stackscript_id = linode_stackscript.vpn_bot_stackscript.id
#   stackscript_data = {
#     "TAG"                  = "v_0.1.4"
#     "ALLOWED_CHAT_IDS"     = "451426008,285520565"
#     "STACKSCRIPT_ID"       = 1280586
#     "GITHUB_TOKEN"         = var.github_token
#     "BOT_API_KEY"          = var.telegram_token
#     "DOCKERHUB_USERNAME"   = var.dockerhub_username
#     "DOCKERHUB_TOKEN"      = var.dockerhub_token
#     "API_KEY_LINODE"       = var.linode_api_key
#   }
# }
