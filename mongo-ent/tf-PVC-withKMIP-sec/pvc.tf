resource "kubernetes_persistent_volume_claim" "pvc-mongodb-standalone" {
  metadata {
    name = "pvc-mongodb-standalone"
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = var.sc_name
    resources {
      requests = {
        storage = "5Gi"
      }
    }
  }
}