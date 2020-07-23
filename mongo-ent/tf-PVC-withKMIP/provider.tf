provider "kubernetes" {
  load_config_file = "true"
  config_path      = "../../install-vault-raft/tmp/k8s_config"
}