# mongodb Enterprise

## AKS - Create Standalone Mongo DB (with PVC)
Go to standalone-withPVC directory to review AKS resources:
```
cd standalone-withPVC
```
* configmap.yaml - used to mount the mongodb data volume
* storageclass.yaml - custom class for mongo
* secrets.yaml - docker auth to deploy custom mongo-ent image
* persistent-volume-claim.yaml - mongo storage volume
* service.yaml - expose the db service so we can connect

### Update secrets.yaml with your docker auth secret
To pull down your docker image you need to allow K8 to login to your docker repo.  To do this locally we are putting a reference to our docker creds into a k8 secret and referencing this in our statefulset.  To create a k8 secret using your docker creds try the following:
```
docker login
cat ~/.docker/config.json
``` 

You should see your token or a reference to it.  To create a docker repo secret you need to base64 encode the json file config.json and put this value in **./secrets.yaml**
```
cat ~/.docker/config.json | base64
```

### AKS - Create Azure-Standalone-PVC
Configure a custom storageclass and create a PVC using it.  then deploy a statefulset leveraging this PVC in Azure.

```
kubectl apply -f storageclass.yaml
kubectl apply -f persistent-volume-claim.yaml
kubectl apply -f secrets.yaml
kubectl apply -f configmap.yaml
kubectl apply -f service.yaml
kubectl apply -f statefulset.yaml
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
kubectl exec -it mongodb-standalone-0 sh
mongo mongodb://mongodb-standalone-0.database:27017
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
You should see your user entry from the find command above.  THis means your data persisted


### Cleanup
```
kubectl delete -f statefulset.yaml
kubectl delete -f persistent-volume-claim.yaml
kubectl delete -f storageclass.yaml
kubectl delete -f secrets.yaml
kubectl delete -f configmap.yaml
kubectl delete -f service.yaml
```
