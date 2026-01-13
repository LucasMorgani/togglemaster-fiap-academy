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