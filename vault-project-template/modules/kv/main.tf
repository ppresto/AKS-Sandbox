# mounting kv secret engine
resource "vault_mount" "kv" {
  path        = var.kv_path
  type        = "kv-v2"
  description = "kv secret engine managed by Terraform"
}

# storing secret
resource "vault_generic_secret" "secret" {
  path = var.kv_secret_path
  data_json = var.kv_secret_data

  depends_on = [vault_mount.kv]
}