terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "2.37.0"
    }
  }
}


# resource "linode_firewall" "resume_firewall" {
#   label = "resume_firewall"

#   inbound {
#     label    = "allow-ssh"
#     action   = "ACCEPT"
#     protocol = "TCP"
#     ports    = "22"
#     ipv4     = ["0.0.0.0/0"]
#     ipv6     = ["::/0"]
#   }

#   inbound {
#     label    = "allow-http"
#     action   = "ACCEPT"
#     protocol = "TCP"
#     ports    = "80"
#     ipv4     = ["0.0.0.0/0"]
#     ipv6     = ["::/0"]
#   }

#   inbound {
#     label    = "allow-https"
#     action   = "ACCEPT"
#     protocol = "TCP"
#     ports    = "443"
#     ipv4     = ["0.0.0.0/0"]
#     ipv6     = ["::/0"]
#   }

#   inbound_policy = "DROP"

#   outbound {
#     label    = "allow-specific-http"
#     action   = "ACCEPT"
#     protocol = "TCP"
#     ports    = "80"
#     ipv4     = [
#         "91.189.91.81/32", # ubuntu.com
#         "23.53.41.91/32", # linode.com
#         "140.82.112.4/32", # github.com
#         "185.199.108.133/32", # githubusercontent.com
#         "185.199.109.133/32", # githubusercontent.com
#         "185.199.110.133/32", # githubusercontent.com
#         "185.199.11.133/32",# githubusercontent.com
#         "44.219.3.189/32", # docker.com
#         "44.193.181.103/32", # docker.com
#         "3.224.227.198/32" # docker.com
#     ]
#   }

#   outbound {
#     label    = "allow-specific-https"
#     action   = "ACCEPT"
#     protocol = "TCP"
#     ports    = "443"
#     ipv4     = [
#         "91.189.91.81/32", # ubuntu.com
#         "23.53.41.91/32", # linode.com
#         "140.82.112.4/32", # github.com
#         "185.199.108.133/32", # githubusercontent.com
#         "185.199.109.133/32", # githubusercontent.com
#         "185.199.110.133/32", # githubusercontent.com
#         "185.199.11.133/32",# githubusercontent.com
#         "44.219.3.189/32", # docker.com
#         "44.193.181.103/32", # docker.com
#         "3.224.227.198/32" # docker.com
#     ]
#   }

#   outbound_policy = "ACCEPT"

#   linodes = [linode_instance.resume_app.id]
# }


# resource "linode_instance" "resume_app" {
#     label = "resume-app"
#     image = "linode/ubuntu20.04"
#     region = "eu-central"
#     type = "g6-nanode-1"
#     root_pass = var.root_pass

#     authorized_keys = [
#       var.ssh_public_key
#     ]

# }

# resource "linode_volume" "resume_volume" {
#   label = "resume-volume"
#   size  = 10
#   region = linode_instance.resume_app.region
#   linode_id = linode_instance.resume_app.id
# }



# resource "linode_domain" "mykytaprokaiev_com" {
#     type = "master"
#     domain = "mykytaprokaiev.com"
#     soa_email = var.email
# }

# resource "linode_domain_record" "www" {
#     domain_id = linode_domain.mykytaprokaiev_com.id
#     name = "www"
#     record_type = "A"
#     target = linode_instance.resume_app.ip_address
#     ttl_sec = 100
# }

# resource "linode_domain_record" "root" {
#     domain_id = linode_domain.mykytaprokaiev_com.id
#     name = ""
#     record_type = "A"
#     target = linode_instance.resume_app.ip_address
#     ttl_sec = 100
# }
