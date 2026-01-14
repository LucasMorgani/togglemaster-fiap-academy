output "dynamodb_url" {
  description = "URL da fila SQS"
  value       = module.resources.dynamodb_url
}