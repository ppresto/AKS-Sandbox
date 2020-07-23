# Provision AKS and Install Vault with Integrated Storage
Using Terraform we will provision a 3 node AKS cluster and deploy a 3 pod vault cluster.  To deploy vault we will use the tf helm provider.  To initialize, unseal, join peers, and apply our enterprise license we will use **local-exec** to run our vault init scripts.  If everything is successful you will have a fully operational vault cluster in AKS using auto-unseal.
Note: 
* sensitive vault data will be stored in `tmp/cluster-keys.json`
* sensitive k8s data will be stored in `tmp/k8s_config`

## Provisioning
Update `vault.auto.tfvars` with your environment information like resource group, and k8s cluster name.

### Provision both AKS and Vault
```
cp ex-aks-vault-init-full.tf.disable main.tf
source env.sh
terraform init
terraform apply -auto-approve
```
You should have a fully running AKS cluster with Vault deployed, initialized, and unsealed.  If anything went wrong refer to `./README-manual-steps.md` and walk through the steps manually.   For AKS and Vault sensitive information look at `./tmp`

### Provision Vault in existing AKS Cluster
If you built the AKS cluster from this repo then you also built the Azure Key Vault, and Key that we will need to properly setup auto unseal.  Review the terraform output for these two values.
```
cp ex-vault-init.tf.disable maint.tf
```
`vi main.tf` and update the vault name and key name with the correct information.

Now TF is ready.  Lets Provision our cluster.
```
source env.sh
terraform init
terraform apply -auto-approve
```

## Next Steps...
### Setup a Vault Project
Now lets create a project or vault namespace that we can configure all our auth methods, secrets engines, and policies too using terraform.  This will give us a quick way to build/destroy various configurations at anytime without affecting the root vault.
[Setup a Vault Namespace Project](./tree/master/vault-project-template "Setup a Vault Namespace Project")

```
cd ../vault_project_template
```