data "azurerm_client_config" "current" {}

resource "helm_release" "vault" {
  name       = "vault"
  repository = "https://helm.releases.hashicorp.com" 
  chart      = "vault"
  wait       = true
  timeout    = "120"

  set {
    name  = "server.image.repository"
    value = "hashicorp/vault-enterprise"
  }
  set {
    name  = "server.image.tag"
    value = "1.4.2_ent"
  }
  set {
    name  = "server.ha.enabled"
    value = "true"
  }
  set {
    name  = "server.ha.raft.enabled"
    value = "true"
  }
  values = [
    templatefile("${path.module}/values-unseal.yaml", { 
      client_id = data.azurerm_client_config.current.client_id,
      client_secret = var.ARM_CLIENT_SECRET,
      tenant_id = data.azurerm_client_config.current.tenant_id,
      vault_name = var.vault_name,
      key_name =  var.key_name
    })
    #"${file("values-unseal.yaml")}"
  ]
}