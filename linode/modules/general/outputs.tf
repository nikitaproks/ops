output "postgres_host" {
  value = linode_database_postgresql_v2.self_hosted_database.host_primary
}

output "postgres_port" {
  value = linode_database_postgresql_v2.self_hosted_database.port
}
