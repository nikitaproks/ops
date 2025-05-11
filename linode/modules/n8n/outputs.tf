output "n8n_public_ipv4" {
  value = linode_instance.n8n_instance.ip_address
}
