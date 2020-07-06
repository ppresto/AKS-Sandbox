variable "config_path" {
  description = "path to a kubernetes config file"
  default = "/Users/patrickpresto/.kube/config"
}

resource "null_resource" "kubectl_apply" {
  triggers = {
    config_contents = filemd5(var.config_path)
  }
  
  provisioner "local-exec" {
    #command = "kubectl apply --kubeconfig ${var.config_path} -f ${var.k8s_yaml}"
    command = "kubectl exec -ti vault-0 -- vault operator init -key-shares=1 -key-threshold=1 -format=json > cluster-keys.json"
  }
}