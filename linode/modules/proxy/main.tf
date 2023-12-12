terraform {
    required_providers {
        linode = {
            source  = "linode/linode"
            version = "1.16.0"
        }
    }
}

resource "linode_stackscript" "shadowsocks" {
    label = "shadowsocks"
    description = "Does shadowsocks install and config"
    script = file("./stackscripts/config_shadowsocks.sh")
    images = ["linode/ubuntu20.04", "linode/ubuntu22.04"]
    rev_note = "initial version"
  
}

resource "linode_instance" "dallas_proxy" {
    label="dallas-proxy"
    image="linode/ubuntu20.04"
    type="g6-nanode-1"
    region="us-central"
    root_pass = var.root_pass

    stackscript_id = linode_stackscript.shadowsocks.id
    stackscript_data = {
        "SERVER_PORT" = "8388"
        "PASSWORD" = var.shadow_pass
        "LOCAL_PORT" = "1080"
        "METHOD" = "aes-256-gcm"
        "TIMEOUT" = "300"
    }
}

resource "linode_instance" "singapore_proxy" {
    label="singapore-proxy"
    image="linode/ubuntu20.04"
    type="g6-nanode-1"
    region="ap-south"
    root_pass = var.root_pass

    stackscript_id = linode_stackscript.shadowsocks.id
    stackscript_data = {
        "SERVER_PORT" = "8388"
        "PASSWORD" = var.shadow_pass
        "LOCAL_PORT" = "1080"
        "METHOD" = "aes-256-gcm"
        "TIMEOUT" = "300"
    }
}