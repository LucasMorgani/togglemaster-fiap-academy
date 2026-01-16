#Adding kubernetes secret host url endpoint
#auth-service
resource "kubernetes_secret_v1" "auth_db_secret_host" {
  depends_on = [
    kubernetes_namespace_v1.auth-service
  ]

  metadata {
    name      = "auth-db-secret-host"
    namespace = "auth-service"
  }

  data = {
    POSTGRES_HOST = var.db_auth_endpoint
  }

  type = "Opaque"
}

#flag-service
resource "kubernetes_secret_v1" "flag_db_secret_host" {
  depends_on = [
    kubernetes_namespace_v1.flag-service
  ]

  metadata {
    name      = "flag-db-secret-host"
    namespace = "flag-service"
  }

  data = {
    POSTGRES_HOST = var.db_flag_endpoint
  }

  type = "Opaque"
}

#targeting-service
resource "kubernetes_secret_v1" "targeting_db_secret_host" {
  depends_on = [
    kubernetes_namespace_v1.targeting-service
  ]

  metadata {
    name      = "targeting-db-secret-host"
    namespace = "targeting-service"
  }

  data = {
    POSTGRES_HOST = var.db_targeting_endpoint
  }

  type = "Opaque"
}

#evaluation-service
data "aws_region" "current" {}
resource "kubernetes_secret_v1" "evaluation_db_endpoint" {
  depends_on = [
    kubernetes_namespace_v1.evaluation-service
  ]

  metadata {
    name      = "evaluation-db-secret-host"
    namespace = "evaluation-service"
  }

  data = {
    REDIS_URL   = "redis://${var.evaluation_db_endpoint}:6379"
    AWS_REGION  = data.aws_region.current.id
    AWS_SQS_URL = var.sqs_queue_url
  }

  type = "Opaque"
}

#analytics-service
resource "kubernetes_secret_v1" "analytics_db_endpoint" {
  depends_on = [
    kubernetes_namespace_v1.analytics-service
  ]

  metadata {
    name      = "analytics-db-secret-host"
    namespace = "analytics-service"
  }

  data = {
    AWS_DYNAMODB_TABLE = var.dynamodb_url
    AWS_REGION         = data.aws_region.current.id
    AWS_SQS_URL        = var.sqs_queue_url
  }

  type = "Opaque"
}