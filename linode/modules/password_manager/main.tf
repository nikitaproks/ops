terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "2.37.0"
    }
  }
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
}

resource "linode_domain_record" "subdomain_pm" {
  domain_id   = var.mykytaprokaiev_com_domain_id
  name        = "pm"
  record_type = "A"
  target      = linode_instance.password_manager_instance.ip_address
  ttl_sec     = 300
}

resource "linode_domain_record" "spf" {
  domain_id   = var.mykytaprokaiev_com_domain_id
  name        = ""
  record_type = "TXT"
  target      = "v=spf1 include:_spf.mailersend.net ~all"
}

resource "linode_domain_record" "dkim" {
  domain_id   = var.mykytaprokaiev_com_domain_id
  name        = "mlsend2._domainkey"
  record_type = "CNAME"
  target      = "mlsend2._domainkey.mailersend.net"
}


resource "linode_domain_record" "return_path" {
  domain_id   = var.mykytaprokaiev_com_domain_id
  name        = "mta"
  record_type = "CNAME"
  ttl_sec     = 3600
  target      = "mailersend.net"
}

# Security
resource "linode_firewall" "pm_firewall" {
  label = "pm-firewall"

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

  linodes = [linode_instance.password_manager_instance.id]
}



# Provisioning
resource "null_resource" "provision_password_manager" {
  depends_on = [linode_instance.password_manager_instance]

  triggers = {
    instance_id = linode_instance.password_manager_instance.id
  }

  connection {
    host        = linode_instance.password_manager_instance.ip_address
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
    source      = "scripts/start_pm.sh"
    destination = "/tmp/start_pm.sh"
  }

  # Make scripts executable
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/mount_volume.sh",
      "chmod +x /tmp/install_docker.sh",
      "chmod +x /tmp/start_pm.sh"
    ]
  }

  # Run the mount_volume script
  provisioner "remote-exec" {
    inline = [
      "bash /tmp/mount_volume.sh /dev/disk/by-id/scsi-0Linode_Volume_password-manager-volume ${var.mount_dir}"
    ]
  }

  # Run the install_docker script
  provisioner "remote-exec" {
    inline = [
      "bash /tmp/install_docker.sh"
    ]
  }

  # Run the start_pm script with parameters
  provisioner "remote-exec" {
    inline = [
      "bash /tmp/start_pm.sh '${var.admin_token}' pm.mykytaprokaiev.com ${var.mount_dir}"
    ]
  }
}
