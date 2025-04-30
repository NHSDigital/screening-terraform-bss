

resource "aws_elasticache_replication_group" "example" {
  automatic_failover_enabled  = var.elasticache_automatic_failover_enabled
  preferred_cache_cluster_azs = var.elasticache_azs
  replication_group_id        = var.name
  description                 = var.description
  node_type                   = var.elasticache_node_type
  transit_encryption_enabled  = var.elasticache_encryption_in_transit
  at_rest_encryption_enabled  = var.elasticache_encryption_at_rest
  num_cache_clusters          = var.elasticache_cluster_count
  parameter_group_name        = var.elasticache_parameter_group_name
  port                        = var.elasticache_port
  auth_token                  = var.auth_token

  lifecycle {
    ignore_changes = [num_cache_clusters]
  }
}

resource "aws_elasticache_cluster" "replica" {
  count = 1

  cluster_id           = "tf-rep-group-1-${count.index}"
  replication_group_id = aws_elasticache_replication_group.example.id
}
