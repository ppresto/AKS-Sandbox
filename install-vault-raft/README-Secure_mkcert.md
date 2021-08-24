# Provision AKS and Install Vault with Integrated Storage
Using Terraform we will provision a 3 node AKS cluster and deploy a 3 pod vault cluster.  To deploy vault we will use the tf helm provider.  To initialize, unseal, join peers, and apply our enterprise license we will use **local-exec** to run our vault init scripts.  If everything is successful you will have a fully operational vault cluster in AKS using auto-unseal.
Note: 
* sensitive vault data will be stored in `tmp/cluster-keys.json`
* sensitive k8s data will be stored in `tmp/k8s_config`

## Provisioning
Update `vault.auto.tfvars` with your environment information like resource group, and k8s cluster name.

### Prereq
Export azure environment variables
```
ARM_SUBSCRIPTION_ID
ARM_CLIENT_SECRET
ARM_TENANT_ID
ARM_CLIENT_ID
```
### Create K8s Namespace and TLS Certs to run Vault securely
Use your existing CA and cert provisioning process.  If you dont have one you can use mkcert to create a development (non prod) cert to test with.  There is a sample script that will put everything you need in ./tmp/tls/.
```
./scripts/mkcert.sh ./tmp/tls
```
Create Namespace
This is found in `vault.auto.tfvars: k8s_namespace` and defaults to **vault**
```
#export ns=vault
export ns=default
kubectl create namespace $ns
```

Add these files as secrets to K8s
```
kubectl -n $ns create secret tls tls-server --cert=tmp/tls/server.crt --key=tmp/tls/server.key
kubectl -n $ns create secret tls tls-ca --cert=tmp/tls/ca.crt --key=tmp/tls/rootCA-key.pem

```

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
curl -k -v https://vault-0.vault-internal:8200/v1/sys/health
```

Review Certificate CN/SAN 
```
openssl x509 -in tmp/tls/vault.crt -text -noout
```