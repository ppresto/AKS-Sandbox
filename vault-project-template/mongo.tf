module "ns_mongo" {
  source    = "./modules/namespace"
  namespace = "mongo"
}

module "approle_mongo" {
  source                    = "./modules/approle"
  role_depends_on           = module.ns_mongo.id
  namespace                 = "mongo"
  approle_path              = var.approle_path
  role_name                 = var.role_name
  k8s_path                  = var.k8s_path
  kv_path                   = var.kv_path
  ssh_path                  = var.ssh_path
  default_lease_ttl_seconds = "3600s"
  max_lease_ttl_seconds     = "10800s"
  policies                  = ["default", "terraform"]
}

output "role_id_mongo" {
  value = module.approle_mongo.role_id
}

output "secret_id_mongo" {
  value = module.approle_mongo.secret_id
}

output "namespace_mongo" {
  value = "mongo"
}

output "k8s_path_mongo" {
  value = var.k8s_path
}
output "kv_path_mongo" {
  value = var.kv_path
}

output "approle_path_mongo" {
  value = module.approle_mongo.approle_path
}

output "ssh_path_mongo" {
  value = module.approle_mongo.ssh_path
}

output "role_name_mongo" {
  value = module.approle_mongo.role_name
}