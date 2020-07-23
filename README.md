# AKS-Sandbox
This Repo sets up an AKS cluster and includes modules to install additional services to it.
This includes:

* Install Vault with integrated storage using Azure key vault for auto-unseal
  * Automatically init, unseal, join raft peers, and apply enterprise license

* Use vault_project_template to create a namespace with its own approle that will config all auth methods, engines, policies
  * This repo includes an example for k8s auth, kv, and a script to setup kmip

* Deploy a mongo db server that will use kmip and inject its cert from vault's k/v.

## Pre Req
* Azure Subscription 

## Build AKS Cluster

Use the root directory to build an AKS Cluster.  If you want to automatically deploy AKS and vault together you can skip this page and look at `./install-vault-raft/main-aks-and-vault.tf.example`

To deploy AKS update the aks.auto.tfvars file with your information. 
See a working example: `cat ./aks.auto.tfvars` 
```
prefix="ppresto"
MY_RG="aks-rg"
k8s_clustername="example-aks1"
location = "West US 2"
ssh_user = "patrickpresto"
public_ssh_key_path = "~/.ssh/id_rsa.pub"
my_tags = {
        env = "dev"
        owner = "ppresto"
    }
```

Setup Terraforms TF_VAR variables for required Azure ARM inputs.  Input your values.
```
export TF_VAR_ARM_CLIENT_ID=
export TF_VAR_ARM_TENANT_ID=
export TF_VAR_ARM_SUBSCRIPTION_ID=
export TF_VAR_ARM_CLIENT_SECRET=

```

Use Terraform to build k8s platform.
```
terraform init
terraform plan
terraform apply
```

## Connect to AKS
```
MY_RG=$(terraform output resource_group_name)
MY_CN=$(terraform output azure_aks_cluster_name)

az login
az aks get-credentials --resource-group ${MY_RG} --name ${MY_CN}
kubectl get pods
```