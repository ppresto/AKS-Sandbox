# Provision Vault with Integrated Storage
Using the terraform helm provider we will deploy a TLS enabled vault cluster using internal storage on AKS.  Later we will use terraform to configure vault with namespaces to isolate our projects from each other using the sample mongodb project.  Finally we will deploy a standalone mongodb that will inject kmip certs from a specific vault namespace to securely encrypt its PVC.

### Prereq
Build a 3-5 node AKS cluster and greate an Azure keyvault key to use for auto-unseal.  The base of this repo `cd ../` has the terraform code to provision this for you.  

Export azure environment variables using `TF_VAR_` so terraform can pick these up when you run it.
```
TF_VAR_ARM_SUBSCRIPTION_ID
TF_VAR_ARM_CLIENT_SECRET
TF_VAR_ARM_TENANT_ID
TF_VAR_ARM_CLIENT_ID
```
**Note**: If you want to provision both AKS and vault infrastructure together you can do that using Option 2 below.  These components are often owned by different teams and typically managed using their own tfstate.

## Overview
* Create vault server TLS certs and K8s secrets
* Build Vault cluster using helm chart
* Initialize, unseal, join peers, and apply Enterprise license

Next Steps:
* `./vault-project-template`
  * Configure vaults root with per project appid, namespaces
  * Configure sample project namespace (mongo, mongo-sec)
    * This will setup k8s auth, KMIP, and put kmip certs in k/v store to be consumed
* `./mongo-ent`
  * Deploy Mongodb with vault-k8s to inject KMIP certs and encrypt PVC.

## Provisioning
Update `vault.auto.tfvars` with your environment information like resource group, and k8s cluster name.


### Create K8s Namespace and TLS Certs to run Vault securely
Use your existing CA and cert provisioning process.  If you dont have one you can use k8s CA which we will do here.  Use this script to generate everything you need in ./tmp/tls/, and create the K8s secrets and approved csr.
```
source env.sh
./scripts/genServerCert-k8ca.sh
kubectl get secrets
kubectl get csr
```
Note:  `source env.sh` should pull your AKS info from terraform outputs and authenticate you to your cluster so you can start using kubectl from the CLI.

Create Namespace if you dont want vault running in the default one.
This is found in `vault.auto.tfvars: k8s_namespace`
```
export ns=vault
kubectl create namespace $ns
```

### (Option 1) Provision Vault in existing AKS Cluster
If you built the AKS cluster from this repo then you also built the Azure Key Vault, and Key that we will need to properly setup auto unseal.  Review the terraform output for these two values. For a quicker automated setup we will use the `ex-vault-init-full`.  This uses **local-exec** with our vault init script to take care of all post installation tasks.  One completed you will have a fully operational vault cluster in AKS using auto-unseal and TLS enabled.

Note when using `ex-vault-init-full`:
* sensitive vault data will be stored in `tmp/cluster-keys.json`
* sensitive k8s data will be stored in `tmp/k8s_config`
```
cp ex-vault-init.tf.disable maint.tf
vi aks.auto.tfvars
```
Update `aks.auto.tfvars` with your env specific information!!


Now TF is ready.  Lets Provision our cluster.
```
source env.sh
terraform init
terraform apply -auto-approve
```

You should have a fully running AKS cluster with Vault deployed, initialized, and unsealed.  If anything went wrong refer to `./README-manual-steps.md` and walk through the steps manually.   For AKS and Vault sensitive information look at `./tmp`

### (Option 2) Provision both AKS and Vault
To build both AKS and Vault at the same time for demo or test purposes use the `ex-aks-vault-init-full` example.  Be sure to udpate the .tfvars with your info first.

```
cp ex-aks-vault-init-full.tf.disable main.tf
source env.sh
terraform init
terraform apply -auto-approve
```

## Next Steps...
### Setup a Vault Project
Now lets create a project or vault namespace that we can configure all our auth methods, secrets engines, and policies too using terraform.  This will give us a quick way to build/destroy various configurations at anytime without affecting the root vault.
[Setup a Vault Namespace Project](../vault-project-template "Setup a Vault Namespace Project")

```
cd ../vault_project_template
```


## Troubleshooting
Start a test pod with the vault sa.  configure env, mounts, etc... for testing.

```
kubectl apply -f scripts/pod-test.yaml
```

Use curl to get server TLS information.  You should see output.
```
curl -v https://vault-0.vault-internal:8200
curl --cacert /vault/userconfig/vault-server-tls/vault.ca https://vault-0.vault-internal:8200/v1/sys/health
```

openssl
```
openssl x509 -in tmp/tls/vault.crt -text -noout
```