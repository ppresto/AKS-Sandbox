resource "kubernetes_secret" "github" {
  metadata {
    name = var.docker_registry_secret_name
  }

  data = {
    ".dockerconfigjson" = "${file(var.docker_registry_file)}"
  }

  type = "kubernetes.io/dockerconfigjson"
}

resource "kubernetes_secret" "kmip-certs" {
  metadata {
    name = "kmip-certs"
  }

  data = {
    "vault-ca-kmip.pem"       = var.kmip_ca
    "vault-cert-tenant-1.pem" = var.kmip_pem
  }

  type = "Opaque"
}