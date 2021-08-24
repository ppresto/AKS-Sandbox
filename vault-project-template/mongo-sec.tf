module "ns_mongo-sec" {
  source    = "./modules/namespace"
  namespace = "mongo-sec"
}

module "approle_mongo-sec" {
  source                    = "./modules/approle"
  role_depends_on           = module.ns_mongo-sec.id
  namespace                 = "mongo-sec"
  approle_path              = var.approle_path
  role_name                 = var.role_name
  k8s_path                  = var.k8s_path
  kv_path                   = var.kv_path
  ssh_path                  = var.ssh_path
  default_lease_ttl_seconds = "3600s"
  max_lease_ttl_seconds     = "10800s"
  policies                  = ["default", "terraform"]
}

output "role_id_mongo-sec" {
  value = module.approle_mongo-sec.role_id
}

output "secret_id_mongo-sec" {
  value = module.approle_mongo-sec.secret_id
}

output "namespace_mongo-sec" {
  value = "mongo-sec"
}

output "k8s_path_mongo-sec" {
  value = var.k8s_path
}
output "kv_path_mongo-sec" {
  value = var.kv_path
}

output "approle_path_mongo-sec" {
  value = module.approle_mongo-sec.approle_path
}

output "ssh_path_mongo-sec" {
  value = module.approle_mongo-sec.ssh_path
}

output "role_name_mongo-sec" {
  value = module.approle_mongo-sec.role_name
}