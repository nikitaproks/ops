terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "2.37.0"
    }
  }
}

resource "linode_volume" "n8n_volume" {
  label     = "n8n-volume"
  size      = 10
  region    = linode_instance.n8n_instance.region
  linode_id = linode_instance.n8n_instance.id
}

resource "linode_instance" "n8n_instance" {
  label     = "n8n-instance"
  image     = "linode/ubuntu20.04"
  region    = "eu-central"
  type      = "g6-nanode-1"
  root_pass = var.root_pass

  authorized_keys = [
    var.ssh_public_key
  ]
}

resource "linode_domain_record" "subdomain_n8n" {
  domain_id   = var.mykytaprokaiev_com_domain_id
  name        = "n8n"
  record_type = "A"
  target      = linode_instance.n8n_instance.ip_address
  ttl_sec     = 300
}

# Security
resource "linode_firewall" "n8n_firewall" {
  label = "n8n-firewall"

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

  inbound {
    label    = "allow-ssh"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "22"
    ipv4     = ["95.91.235.53/32"]
  }


  inbound_policy  = "DROP"
  outbound_policy = "ACCEPT"

  linodes = [linode_instance.n8n_instance.id]
}



# Provisioning
resource "null_resource" "provision_n8n" {
  depends_on = [linode_instance.n8n_instance]

  triggers = {
    instance_id = linode_instance.n8n_instance.id
  }

  connection {
    host        = linode_instance.n8n_instance.ip_address
    user        = "root"
    private_key = file(var.ssh_private_key_path)
  }

  # Upload scripts
  provisioner "file" {
    source      = "scripts/mount_volume.sh"
    destination = "/tmp/mount_volume.sh"
  }

  provisioner "file" {
    source      = "scripts/install_docker.sh"
    destination = "/tmp/install_docker.sh"
  }


  provisioner "file" {
    source      = "scripts/start_n8n.sh"
    destination = "/tmp/start_n8n.sh"
  }

  provisioner "file" {
    source      = "certificates/self-hosted-database-ca-certificate.crt"
    destination = "/tmp/self-hosted-database-ca-certificate.crt"
  }

  # Make scripts executable
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/mount_volume.sh",
      "chmod +x /tmp/install_docker.sh",
      "chmod +x /tmp/start_n8n.sh"
    ]
  }

  # Run the mount_volume script
  provisioner "remote-exec" {
    inline = [
      "bash /tmp/mount_volume.sh /dev/disk/by-id/scsi-0Linode_Volume_n8n-volume ${var.mount_dir}"
    ]
  }


  # Run the install_docker script
  provisioner "remote-exec" {
    inline = [
      "bash /tmp/install_docker.sh"
    ]
  }

  # Run the start_n8n script with parameters
  provisioner "remote-exec" {
    inline = [
      "bash /tmp/start_n8n.sh ${var.postgres_host} ${var.postgres_port} ${var.postgres_user} ${var.postgres_password} n8n.mykytaprokaiev.com ${var.mount_dir}"
    ]
  }
}
