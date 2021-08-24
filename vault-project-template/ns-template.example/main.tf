module "policy" {
  source = "../modules/policy"

  policy_name = var.policy_name
  policy_code = var.policy_code
}

module "kv" {
  source = "../modules/kv"
  kv_path        = "kv"
  kv_secret_path = "kv/database/config"
  kv_secret_data = "{\"username\": \"admin\", \"password\": \"password\", \"ttl\": \"20s\"}"
}

module "k8s" {
  source = "../modules/k8s"

  kubernetes_host = var.kubernetes_host
  kubernetes_ca_cert = var.kubernetes_ca_cert
  token_reviewer_jwt = var.token_reviewer_jwt
  policy_name = var.policy_name
}

module "ssh" {
  source = "../modules/ssh"

  ssh_ca_allowed_users = var.ssh_ca_allowed_users
  ssh_otp_allowed_users = var.ssh_otp_allowed_users
}

#module "gcp" {
#  source = "../modules/gcp"

#  gcp_credentials = var.gcp_credentials
#  gcp_role_name   = var.gcp_role_name
#  gcp_bound_zones     = var.gcp_bound_zones
#  gcp_bound_projects  = var.gcp_bound_projects
#  gcp_token_policies  = var.gcp_token_policies
#  gcp_token_ttl       = var.gcp_token_ttl
#  gcp_token_max_ttl   = var.gcp_token_max_ttl
#}