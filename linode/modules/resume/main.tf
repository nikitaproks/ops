terraform {
    required_providers {
        linode = {
            source  = "linode/linode"
            version = "1.16.0"
        }
    }
}


resource "linode_instance" "resume-app" {
    label = "resume-app"
    image = "linode/ubuntu20.04"
    region = "eu-central"
    type = "g6-nanode-1"
}