terraform {
    required_providers {
        linode = {
            source  = "linode/linode"
            version = "2.10.0"
        }
    }
}

provider "linode" {
    token = var.linode_token
}

module "resume_app" {
    source = "./modules/resume"
    root_pass =  var.root_pass
    github_token = var.github_token
    dockerhub_username = var.dockerhub_username
    dockerhub_token = var.dockerhub_token
    db_name = var.db_name
    db_user = var.db_user
    db_pass = var.db_pass
    db_host = var.db_host
    django_secret_key = var.django_secret_key
    allowed_hosts = var.allowed_hosts
    django_superuser_username = var.django_superuser_username
    django_superuser_email = var.django_superuser_email
    django_superuser_password = var.django_superuser_password
    ssh_public_key = var.ssh_public_key
    ssh_private_key_path =  var.ssh_private_key_path
    email = var.email
}

module "proxies" {
    source = "./modules/proxy"
    root_pass =  var.root_pass
    shadow_pass = var.shadow_pass
}