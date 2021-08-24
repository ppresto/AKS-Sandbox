module "policy" {
  source      = "../modules/policy"
  policy_name = var.policy_name
  policy_code = var.policy_code
}

module "kv" {
  source         = "../modules/kv"
  kv_path        = "kv"
  kv_secret_path = "kv/database/config"
  kv_secret_data = "{\"username\": \"admin\", \"password\": \"password\", \"ttl\": \"20s\"}"
}

module "k8s" {
  source             = "../modules/k8s"
  kubernetes_host    = var.kubernetes_host
  kubernetes_ca_cert = var.kubernetes_ca_cert
  token_reviewer_jwt = var.token_reviewer_jwt
  policy_name        = var.policy_name
}