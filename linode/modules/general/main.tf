terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "2.37.0"
    }
  }
}

locals {
  my_ip = "95.91.235.53"
}

resource "linode_database_postgresql_v2" "self_hosted_database" {
  label        = "self-hosted-database"
  engine_id    = "postgresql/17"
  region       = "eu-central"
  type         = "g6-nanode-1"
  cluster_size = 1
}

resource "linode_database_access_controls" "self_hosted_database_access_control" {
  database_id   = linode_database_postgresql_v2.self_hosted_database.id
  database_type = "postgresql"

  allow_list = [local.my_ip, var.n8n_public_ipv4]
}
