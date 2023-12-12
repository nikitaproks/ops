terraform {
    required_providers {
        linode = {
            source  = "linode/linode"
            version = "1.16.0"
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


resource "linode_instance" "resume_app" {
    label = "resume-app"
    image = "linode/ubuntu20.04"
    region = "eu-central"
    type = "g6-nanode-1"
    root_pass = var.root_pass

    stackscript_id = linode_stackscript.docker_stackscript.id
    stackscript_data = {
        "TAG" = "v2023.12.12.9"
        "GITHUB_TOKEN" = var.github_token
        "DOCKERHUB_USERNAME" = var.dockerhub_username
        "DOCKERHUB_TOKEN" = var.dockerhub_token
        "DB_NAME" = var.db_name
        "DB_USER" = var.db_user
        "DB_PASS" = var.db_pass
        "DB_HOST" = var.db_host
        "DB_PORT" = 5432
        "DEBUG" = false
        "DJANGO_SECRET_KEY" = var.django_secret_key
        "ALLOWED_HOSTS" = var.allowed_hosts
        "DJANGO_SUPERUSER_USERNAME" = var.django_superuser_username
        "DJANGO_SUPERUSER_EMAIL" = var.django_superuser_email
        "DJANGO_SUPERUSER_PASSWORD" = var.django_superuser_password
    }

}