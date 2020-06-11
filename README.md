# hcs-az-dev

## Pre Req
* Azure Subscription 

## Build AKS Cluster
Update the aks.auto.tfvars file with your information.  Setup Terraforms required Azure ARM environment variables to connect.

```
cd ./k8s-azure

terraform init

terraform plan

terraform apply
```

## Connect to AKS
```
MY_RG=$(cat ./aks.auto.tfvars  | grep MY_RG | cut -d "=" -f2 | sed "s/\"//g")
MY_CN=$(cat ./aks.auto.tfvars  | grep k8s_clustername | cut -d "=" -f2 | sed "s/\"//g")

az login
az aks get-credentials --resource-group ${MY_RG} --name ${MY_CN}
kubectl get pods
```