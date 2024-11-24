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

module "domains" {
  source = "./modules/domains"
  email  = var.email
}

module "resume_app" {
  source                    = "./modules/resume"
  root_pass                 = var.root_pass
  github_token              = var.github_token
  telegram_token            = var.telegram_token
  backend_api_key           = var.backend_api_key
  dockerhub_username        = var.dockerhub_username
  dockerhub_token           = var.dockerhub_token
  recaptcha_secret_key      = var.recaptcha_secret_key
  recaptcha_site_key        = var.recaptcha_site_key
  db_name                   = var.db_name
  db_user                   = var.db_user
  db_pass                   = var.db_pass
  db_host                   = var.db_host
  django_secret_key         = var.django_secret_key
  django_superuser_username = var.django_superuser_username
  django_superuser_email    = var.django_superuser_email
  django_superuser_password = var.django_superuser_password
  ssh_public_key            = var.ssh_public_key
  ssh_private_key_path      = var.ssh_private_key_path
  email                     = var.email
}

module "proxies" {
  source      = "./modules/proxy"
  root_pass   = var.root_pass
  shadow_pass = var.shadow_pass
}

module "vpn_bot" {
  source               = "./modules/vpn_bot"
  root_pass            = var.root_pass
  github_token         = var.github_token
  telegram_token       = var.vpn_bot_telegram_token
  dockerhub_username   = var.dockerhub_username
  dockerhub_token      = var.dockerhub_token
  ssh_public_key       = var.ssh_public_key
  ssh_private_key_path = var.ssh_private_key_path
  linode_api_key       = var.linode_api_key
  shadow_pass          = var.shadow_pass
}

module "password_manager" {
  source                       = "./modules/password_manager"
  mykytaprokaiev_com_domain_id = module.domains.mykytaprokaiev_com_domain_id
  mykytaprokaiev_com_domain    = module.domains.mykytaprokaiev_com_domain
  ssh_private_key_path         = var.ssh_private_key_path
  root_pass                    = var.root_pass
  ssh_public_key               = var.ssh_public_key
}
