resource "kubernetes_storage_class" "mongodb" {
  metadata {
    name = var.sc_name
  }
  storage_provisioner = "kubernetes.io/azure-disk"
  reclaim_policy      = "Delete"
  #mount_options       = ["file_mode=0700", "dir_mode=0777", "mfsymlinks", "uid=1000", "gid=1000", "nobrl", "cache=none"]
}