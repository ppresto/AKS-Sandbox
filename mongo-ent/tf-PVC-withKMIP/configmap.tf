resource "kubernetes_config_map" "example" {
  metadata {
    name = "mongodb-standalone"
  }

  data = {
    "mongo.conf" = "${file("${path.module}/templates/mongo.conf")}"
  }
}