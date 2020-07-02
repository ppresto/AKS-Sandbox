# mongodb Enterprise
Build the mongodb container based on the mongo docker repo.  Deploy it to Kubernetes using a Persistent Volume Claim (PVC).  

## Build MongoDB Enterprise container 
We will build an enterprise image using the mongo docker project.  

PreReq:
* Sign up for your own free docker account.
* Create your AKS cluster

## Download mongo docker repo and build image
When you build your image use your docker login (ex: ppresto).  This will be required when you try to upload your image.
```
git clone https://github.com/docker-library/mongo.git
cd mongo/<version>

docker build -t ppresto/mongo-ent:4.2 --build-arg MONGO_PACKAGE=mongodb-enterprise --build-arg MONGO_REPO=repo.mongodb.com .
```

## Test the mongo db locally
```
docker run -d --name mongo -t ppresto/mongo-ent:4.2
docker exec -it mongo bash
ps -aux | grep mongod
mongo  #can shell connect and show enterprise prompt?
exit
exit
```

## View logs
```
docker logs mongo | grep enterprise
```

## Push imge to docker repo
Be sure your image name starts with your docker login name (ex: ppresto)
```
docker login
docker images
docker push ppresto/mongo-ent:4.2
```

## AKS - Create Standalone Mongo DB (with PVC)
Go to standalone-withPVC directory to review AKS resources
```
cd standalone-withPVC
```
* configmap.yaml - used to mount the mongodb data volume
* storageclass.yaml - custom class for mongo
* secrets.yaml - docker auth to deploy custom mongo-ent image
* persistent-volume-claim.yaml - mongo storage volume
* statefulsets.yaml - deploy standalone mongodb instance
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

### AKS - Create Mongo Standalone-withPVC
Configure a custom storageclass and create a PVC using it.  then deploy a statefulset leveraging this PVC in AKS.

```
kubectl apply -f storageclass.yaml
kubectl apply -f persistent-volume-claim.yaml
kubectl apply -f secrets.yaml
kubectl apply -f configmap.yaml
kubectl apply -f service.yaml
kubectl apply -f statefulsets.yaml
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

### Cleanup
```
kubectl delete -f statefulsets.yaml
kubectl delete -f persistent-volume-claim.yaml
kubectl delete -f storageclass.yaml
kubectl delete -f secrets.yaml
kubectl delete -f configmap.yaml
kubectl delete -f service.yaml
```

### PVC Notes
kubectl get sc
kubectl get pv pvc
kubectl get pvc <name> -o yaml > pvc.yaml
