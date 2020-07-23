resource "kubernetes_service_account" "mongodb" {
  metadata {
    name = var.sa_name
  }
  #secret {
  #  name = "${kubernetes_secret.example.metadata.0.name}"
  #}
}