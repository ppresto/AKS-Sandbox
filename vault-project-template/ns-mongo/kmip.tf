resource "null_resource" "setup-kmip" {
  triggers = {
    config_contents = filemd5("${path.module}/../scripts/setup_kmip.sh")
  }
  depends_on = [module.policy, module.kv]

  provisioner "local-exec" {
    command = "${path.module}/../scripts/setup_kmip.sh ${var.namespace}"
  }
}

module "kmip-policy" {
  source      = "../modules/policy"
  policy_name = "mongodb"
  policy_code = file("${path.module}/../policies/mongodb-policy.hcl")
}

resource "vault_kubernetes_auth_backend_role" "mongodb" {
  backend                          = var.k8s_path
  role_name                        = "mongodb"
  bound_service_account_names      = ["default", "mongodb"]
  bound_service_account_namespaces = ["default"]
  token_ttl                        = 3600
  token_policies                   = ["mongodb"]
  depends_on                       = [module.k8s]
}

