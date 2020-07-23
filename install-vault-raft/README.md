# Provision AKS and Install Vault with Integrated Storage
Using Terraform we will provision a 3 node AKS cluster and deploy a 3 pod vault cluster.  To deploy vault we will use the tf helm provider.  To initialize, unseal, join peers, and apply our enterprise license we will use **local-exec** to run our vault init scripts.  If everything is successful you will have a fully operational vault cluster in AKS using auto-unseal.
Note: 
* sensitive vault data will be stored in `tmp/cluster-keys.json`
* sensitive k8s data will be stored in `tmp/k8s_config`

## Provisioning
Update `vault.auto.tfvars` with your environment information like resource group, and k8s cluster name.
```
cp main-aks-and-vault.tf.example main.tf
terraform init
terraform apply -auto-approve
```
You should have a fully running AKS cluster with Vault deployed and unsealed.  If anything went wrong refer to `./README-manual-steps.md` and walk through the steps manually.

## Setup a Vault Project
Now we are going to create a project namespace that we can configure all our auth methods, secrets engines, and policies too using terraform.  This will give us a quick way to build/destroy projects at anytime without affecting the root vault.

```
cd ./vault_project_template
```