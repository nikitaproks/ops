terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "2.31.1"
    }
  }
}

# TODO: move this to a stackscript module
resource "linode_stackscript" "mounted_volume_docker_stackscript" {
  label       = "mounted-volume-docker-stackscript"
  description = "Mounts volume and installs docker"
  script      = file("./stackscripts/mounted_volume_docker.sh")
  images      = ["linode/ubuntu20.04", "linode/ubuntu22.04"]
  rev_note    = "initial version"
}

resource "linode_volume" "password_manager_volume" {
  label     = "password-manager-volume"
  size      = 10
  region    = linode_instance.password_manager_instance.region
  linode_id = linode_instance.password_manager_instance.id
}

resource "linode_instance" "password_manager_instance" {
  label     = "password-manager-instance"
  image     = "linode/ubuntu20.04"
  region    = "eu-central"
  type      = "g6-nanode-1"
  root_pass = var.root_pass

  authorized_keys = [
    var.ssh_public_key
  ]

  stackscript_id = linode_stackscript.mounted_volume_docker_stackscript.id
  stackscript_data = {
    # hardcoded due to circular dependency
    "VOLUME_PATH" = "/dev/disk/by-id/scsi-0Linode_Volume_password-manager-volume"
    "MOUNT_DIR"   = var.mount_dir
  }
}

resource "linode_domain_record" "subdomain_pm" {
  domain_id   = var.mykytaprokaiev_com_domain_id
  name        = "pm"
  record_type = "A"
  target      = linode_instance.password_manager_instance.ip_address
  ttl_sec     = 300
}

# TODO: put this into a stackscript and make it common
resource "null_resource" "start_password_manager" {
  depends_on = [linode_instance.password_manager_instance]

  triggers = {
    instance_id = linode_instance.password_manager_instance.id
    volume_id   = linode_volume.password_manager_volume.id
  }

  connection {
    host        = linode_instance.password_manager_instance.ip_address
    user        = "root"
    private_key = file(var.ssh_private_key_path)
  }

  provisioner "remote-exec" {
    inline = [
      # Wait for Docker to be active
      "echo 'Waiting for Docker to start...'",
      "retries=30; while ! systemctl is-active --quiet docker; do sleep 3; retries=$((retries - 1)); if [ $retries -le 0 ]; then echo 'Docker did not start in time'; exit 1; fi; done",
      "echo 'Docker is active'",
      "if [ -d \"password_manager\" ]; then rm -rf password_manager; fi",
      "git clone https://github.com/nikitaproks/password_manager",
      join(
        " && ",
        [
          "export ADMIN_TOKEN='${var.admin_token}'",
          "export DOMAIN=pm.mykytaprokaiev.com",
          "export VAULT_PERSISTENT_PATH=${var.mount_dir}/vault",
          "export CADDY_DATA_PERSISTENT_PATH=${var.mount_dir}/caddy/data",
          "export CADDY_CONFIG_PERSISTENT_PATH=${var.mount_dir}/caddy/config",
          "cd password_manager && docker compose up --build -d"
        ]
      )
    ]
  }
}
