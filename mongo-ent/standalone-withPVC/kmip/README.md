# AKS - Create Standalone Mongo DB (with PVC and KMIP)
Go to standalone-withPVC directory to review AKS resources:
```
cd standalone-withPVC
```
* configmap.yaml - used to mount the mongodb data volume
* storageclass.yaml - custom class for mongo
* secrets.yaml - docker auth to deploy custom mongo-ent image
* persistent-volume-claim.yaml - mongo storage volume
* kmip/statefulset-kmip.yaml - deploy standalone mongodb instance
* service-vault.yaml - expose the db service so we can connect
* kmip/service-vault-kmip.yaml - expose KMIP port

### Vault - Enable KMIP and generate a certificate for FDE
Review the commands in ../../vault-with-raft/kmip to configure KMIP.  Execute commands manually on CLI.
```
cat ../../vault-with-raft/kmip/kmip_vault_config.sh
```

### AKS - Create Azure-Standalone-PVC
Configure a custom storageclass and create a PVC using it.  then deploy a statefulset leveraging this PVC in Azure.

```
kubectl apply -f storageclass.yaml
kubectl apply -f persistent-volume-claim.yaml
kubectl apply -f secrets.yaml
kubectl apply -f configmap.yaml
kubectl apply -f service-vault.yaml
kubectl apply -f service-vault-kmip.yaml
kubectl apply -f statefulset-kmip.yaml
```

Wait for your deployment to fully start.
```
kubectl get pods
kubectl logs mongodb-standalone-0
```

#### Test mongodb deployment
1. Connect to the pod
2. Connect to the database
3. Login with static admin credentials
4. Create new collection of users with your name
5. Verify your collection data

```
kubectl exec -it mongodb-standalone-kmip-0 sh
mongo mongodb://mongodb-standalone-kmip-0.database:27017
use admin
db.auth('admin','password')
db.users.insert({name: 'Patrick'})
show collections
db.users.find()
``` 

Now lets see if the PVC is working.  We will destroy the db, recreate it, and see if the data persists.

```
kubectl delete statefulsets mongodb-standalone
kubectl apply -f statefulsets.yaml

kubectl exec -it mongodb-standalone-0 sh
mongo mongodb://mongodb-standalone-0.database:27017
use admin
db.auth('admin','password')
show collections
db.users.find()
```

### Cleanup
```
kubectl delete -f statefulset-kmip.yaml
kubectl delete -f persistent-volume-claim.yaml
kubectl delete -f storageclass.yaml
kubectl delete -f secrets.yaml
kubectl delete -f configmap.yaml
kubectl delete -f service-vault.yaml
kubectl delete -f service-vault-kmip.yaml

```

### PVC Notes
kubectl get sc
kubectl get pv pvc
kubectl get pvc <name> -o yaml > pvc.yaml
