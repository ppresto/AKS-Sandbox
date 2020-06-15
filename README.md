# k8s-azure

## Pre Req
* Azure Subscription 

## Build AKS Cluster

Update the aks.auto.tfvars file with your information. 
See a working example: `cat ./k8s-azure/aks.auto.tfvars` 
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
MY_CN=$(terraform output azurerm_kubernetes_cluster_name)

az login
az aks get-credentials --resource-group ${MY_RG} --name ${MY_CN}

kubectl get pods
```