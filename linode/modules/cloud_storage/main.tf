terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "2.10.0"
    }
  }
}

# data "linode_object_storage_cluster" "primary" {
#   id = "eu-central-1"
# }

# resource "linode_object_storage_key" "file_storage_key" {
#   label = "file-access"
# }

# resource "linode_object_storage_bucket" "nik_cloud_bucket" {
#   cluster    = data.linode_object_storage_cluster.primary.id
#   label      = "nik-cloud-bucket"
#   access_key = linode_object_storage_key.file_storage_key.access_key
#   secret_key = linode_object_storage_key.file_storage_key.secret_key
# }
