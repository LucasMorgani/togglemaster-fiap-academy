#Adding kubernetes namespaces to all micro-services

#auth-service namespace
resource "kubernetes_namespace_v1" "auth-service" {
  metadata {
    name = "auth-service"
  }
}
#flag-service namespace
resource "kubernetes_namespace_v1" "flag-service" {
  metadata {
    name = "flag-service"
  }
}
#targeting-service namespace
resource "kubernetes_namespace_v1" "targeting-service" {
  metadata {
    name = "targeting-service"
  }
}
#evaluation-service namespace
resource "kubernetes_namespace_v1" "evaluation-service" {
  metadata {
    name = "evaluation-service"
  }
}
#analytics-service namespace
resource "kubernetes_namespace_v1" "analytics-service" {
  metadata {
    name = "analytics-service"
  }
}