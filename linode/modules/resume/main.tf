terraform {
    required_providers {
        linode = {
            source  = "linode/linode"
            version = "2.10.0"
        }
    }
}


resource "linode_stackscript" "docker_stackscript" {
    label = "docker-stackscript"
    description = "Installs and starts docker containers"
    script = file("./stackscripts/start_docker.sh")
    images = ["linode/ubuntu20.04", "linode/ubuntu22.04"]
    rev_note = "initial version"
  
}

resource "linode_firewall" "resume_firewall" {
  label = "resume_firewall"

  inbound {
    label    = "allow-ssh"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "22"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  inbound {
    label    = "allow-http"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "80"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  inbound {
    label    = "allow-https"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "443"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  inbound_policy = "DROP"

  outbound {
    label    = "allow-specific-http"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "80"
    ipv4     = [
        "91.189.91.81/32", # ubuntu.com
        "23.53.41.91/32", # linode.com
        "140.82.112.4/32", # github.com
        "185.199.108.133/32", # githubusercontent.com
        "185.199.109.133/32", # githubusercontent.com
        "185.199.110.133/32", # githubusercontent.com
        "185.199.11.133/32",# githubusercontent.com
        "44.219.3.189/32", # docker.com
        "44.193.181.103/32", # docker.com
        "3.224.227.198/32" # docker.com
    ]
  }

  outbound {
    label    = "allow-specific-https"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "443"
    ipv4     = [
        "91.189.91.81/32", # ubuntu.com
        "23.53.41.91/32", # linode.com
        "140.82.112.4/32", # github.com
        "185.199.108.133/32", # githubusercontent.com
        "185.199.109.133/32", # githubusercontent.com
        "185.199.110.133/32", # githubusercontent.com
        "185.199.11.133/32",# githubusercontent.com
        "44.219.3.189/32", # docker.com
        "44.193.181.103/32", # docker.com
        "3.224.227.198/32" # docker.com
    ]
  }

  outbound_policy = "ACCEPT"

  linodes = [linode_instance.resume_app.id]
}


resource "linode_instance" "resume_app" {
    label = "resume-app"
    image = "linode/ubuntu20.04"
    region = "eu-central"
    type = "g6-nanode-1"
    root_pass = var.root_pass

    authorized_keys = [
      var.ssh_public_key
    ]
    

    stackscript_id = linode_stackscript.docker_stackscript.id
    stackscript_data = {
        "TAG" = "v2023.12.25.4"
        "DOMAIN" = "mykytaprokaiev.com"
        "VOLUME_PATH" = "/dev/disk/by-id/scsi-0Linode_Volume_resume-volume"
        "EMAIL" = var.email
        "DB_PORT" = 5432
        "FRONTEND_PORT" = 3000
        "DEBUG" = false
        "DJANGO_CORS_ORIGINS" = "https://mykytaprokaiev.com,https://www.mykytaprokaiev.com"
        "GITHUB_TOKEN" = var.github_token
        "DOCKERHUB_USERNAME" = var.dockerhub_username
        "DOCKERHUB_TOKEN" = var.dockerhub_token
        "DB_NAME" = var.db_name
        "DB_USER" = var.db_user
        "DB_PASS" = var.db_pass
        "DB_HOST" = var.db_host
        "DJANGO_SECRET_KEY" = var.django_secret_key
        "ALLOWED_HOSTS" = "mykytaprokaiev.com,www.mykytaprokaiev.com"
        "DJANGO_SUPERUSER_USERNAME" = var.django_superuser_username
        "DJANGO_SUPERUSER_EMAIL" = var.django_superuser_email
        "DJANGO_SUPERUSER_PASSWORD" = var.django_superuser_password
        "RECAPTCHA_SECRET_KEY" = var.recaptcha_secret_key
        "RECAPTCHA_SITE_KEY" = var.recaptcha_site_key
    }

}

resource "linode_volume" "resume_volume" {
  label = "resume-volume"
  size  = 10
  region = linode_instance.resume_app.region
  linode_id = linode_instance.resume_app.id
}



resource "linode_domain" "mykytaprokaiev_com" {
    type = "master"
    domain = "mykytaprokaiev.com"
    soa_email = var.email
}

resource "linode_domain_record" "www" {
    domain_id = linode_domain.mykytaprokaiev_com.id
    name = "www"
    record_type = "A"
    target = linode_instance.resume_app.ip_address
    ttl_sec = 100
}

resource "linode_domain_record" "root" {
    domain_id = linode_domain.mykytaprokaiev_com.id
    name = ""
    record_type = "A"
    target = linode_instance.resume_app.ip_address
    ttl_sec = 100
}