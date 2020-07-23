module "ns_apttus" {
  source    = "./modules/namespace"
  namespace = "apttus"
}

module "approle_apttus" {
  source                    = "./modules/approle"
  role_depends_on           = module.ns_apttus.id
  namespace                 = "apttus"
  approle_path              = var.approle_path
  role_name                 = var.role_name
  k8s_path                  = var.k8s_path
  kv_path                   = var.kv_path
  ssh_path                  = var.ssh_path
  default_lease_ttl_seconds = "3600s"
  max_lease_ttl_seconds     = "10800s"
  policies                  = ["default", "terraform"]
}

output "role_id_apttus" {
  value = module.approle_apttus.role_id
}

output "secret_id_apttus" {
  value = module.approle_apttus.secret_id
}

output "namespace_apttus" {
  value = "apttus"
}

output "k8s_path_apttus" {
  value = var.k8s_path
}
output "kv_path_apttus" {
  value = var.kv_path
}

output "approle_path_apttus" {
  value = module.approle_apttus.approle_path
}

output "ssh_path_apttus" {
  value = module.approle_apttus.ssh_path
}

output "role_name_apttus" {
  value = module.approle_apttus.role_name
}