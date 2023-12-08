terraform {
    required_providers {
        linode = {
            source  = "linode/linode"
            version = "1.16.0"
        }
    }
}

provider "linode" {
    token = var.linode_token
}

module "resume-app" {
    source = "./modules/resume"
    root_pass =  var.root_pass
}