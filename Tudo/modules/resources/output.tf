output "sqs_url" {
  value = aws_sqs_queue.aws_sqs.url
}

#output "rds_id" {
#  value = aws_db_instance.postgres_auth_service.id
#}

# Data from rds db auth
output "db_auth_endpoint" {
  value = aws_db_instance.postgres_auth_service.address
}

#output "db_auth_name" {
#  value = aws_db_instance.postgres_auth_service.db_name
#}

# Data from rds db flag
output "db_flag_endpoint" {
  value = aws_db_instance.postgres_flag_service.address
}

#output "db_flag_name" {
#  value = aws_db_instance.postgres_flag_service.db_name
#}

# Data from rds db targeting
output "db_targeting_endpoint" {
  value = aws_db_instance.postgres_targeting_service.address
}

#output "db_targeting_name" {
#  value = aws_db_instance.postgres_targeting_service.db_name
#}

output "evaluation_db_endpoint" {
  value = aws_elasticache_replication_group.redis_cluster.primary_endpoint_address
}

output "sqs_queue_url" {
  description = "URL da fila SQS"
  value       = aws_sqs_queue.aws_sqs.url
}

output "dynamodb_url" {
  description = "URL da fila SQS"
  value       = aws_dynamodb_table.aws_dynamodb.name
}

