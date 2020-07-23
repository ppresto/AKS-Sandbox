resource "kubernetes_service" "database" {
  metadata {
    name = "database"
  }
  spec {
    cluster_ip = "None"
    selector = {
      app = "database"
    }
  }
}

resource "kubernetes_service" "vault-kmip" {
  metadata {
    name      = "vault-kmip"
    namespace = "default"
  }
  spec {
    selector = {
      "app.kubernetes.io/instance" = "vault"
      "app.kubernetes.io/name"     = "vault"
      component                    = "server"
      #vault-active                 = "true"
    }
    session_affinity = "None"
    port {
      port        = 5696
      target_port = 5696
    }
    publish_not_ready_addresses = true
    type                        = "ClusterIP"
  }
}

resource "kubernetes_service" "vault-kmip-apttus" {
  metadata {
    name      = "vault-kmip-apttus"
    namespace = "default"
  }
  spec {
    selector = {
      "app.kubernetes.io/instance" = "vault"
      "app.kubernetes.io/name"     = "vault"
      component                    = "server"
      #vault-active                 = "true"
    }
    session_affinity = "None"
    port {
      port        = 5696
      target_port = 5697
    }
    publish_not_ready_addresses = true
    type                        = "ClusterIP"
  }
}