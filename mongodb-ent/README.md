# Build MongoDB Enterprise container and deploy to AKS
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

## AKS - Create Standalone Mongo DB (No PVC)
To pull down your docker image you need to allow K8 to login to your docker repo.  To do this locally we are putting a reference to our docker creds into a k8 secret and referencing this in our statefulset.  To create a k8 secret using your docker creds try the following:
```
docker login
cat ~/.docker/config.json
``` 

You should see your token or a reference to it.  To create a docker repo secret you need to base64 encode the json file config.json and put this value in ./secrets.yaml
```
cat ~/.docker/config.json | base64
```

```
cd Standalone-Quick-and-Dirty
kubectl apply -f secrets.yaml
kubectl apply -f service.yaml
kubectl apply -f statefulsets.yaml
```

### Test mongodb deployment
```
kubectl exec -it mongodb-standalone-0 sh
mongo mongodb://mongodb-standalone-0.database:27017
use admin
db.auth('admin','password')
db.users.insert({name: 'Patrick'})
show collections
db.users.find()
```

## AKS - Create Azure-Standalone-PVC
Configure a custom storageclass and create a PVC using it.  then deploy a statefulset leveraging this PVC in Azure.

```
kubectl apply -f storageclass.yaml
kubectl apply -f persistent-volume-claim.yaml
kubectl apply -f secrets.yaml
kubectl apply -f configmap.yaml
kubectl apply -f service.yaml
kubectl apply -f statefulsets.yaml
```

### Test the mongodb and persistent volume is working as expected
`PreReq:`Use the same steps above to test db access and write a collection.  

This time we will destroy the db, recreate, and see if the data persists.

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
