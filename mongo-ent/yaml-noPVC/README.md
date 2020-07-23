# mongodb Enterprise

## AKS - Quickstart Create Mongo DB (no PVC)
Go to standalone-noPVC directory to review the resources:
```
cd standalone-noPVC
```
* secrets.yaml - docker auth to deploy custom mongo-ent image
* service.yaml - expose the db service so we can connect
* statefulsets.yaml - run the mongodb pod

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

### AKS - Create Standalone Mongodb with No PVC

```
kubectl apply -f secrets.yaml
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


### Cleanup

```
kubectl delete -f statefulset.yaml
kubectl delete -f secrets.yaml
kubectl delete -f service.yaml
```
