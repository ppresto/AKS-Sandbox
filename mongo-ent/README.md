# mongodb Enterprise
Build the mongodb container based on the mongo docker repo.  

Note:  
We can deploy this image to Azure Kubernetes AKS.  We can do this using a Persistent Volume Claim (PVC), noPVC, and with KMIP support assuming we have access to an enterprise vault service.  

## Build MongoDB Enterprise container 
We will build an enterprise image using the mongo docker project.  

PreReq:
* Sign up for your own free docker account.
* Create your AKS cluster

## Setup

### Download mongo docker repo and build image
When you build your image use your docker login (ex: ppresto).  This will be required when you try to upload your image.
```
git clone https://github.com/docker-library/mongo.git
cd mongo/<version>

docker build -t ppresto/mongo-ent:4.2 --build-arg MONGO_PACKAGE=mongodb-enterprise --build-arg MONGO_REPO=repo.mongodb.com .
```

### Test the mongo db locally
```
docker run -d --name mongo -t ppresto/mongo-ent:4.2
docker exec -it mongo bash
ps -aux | grep mongod
mongo  #can shell connect and show enterprise prompt?
exit
exit
```

### View logs
```
docker logs mongo | grep enterprise
```

### Push imge to docker repo
Be sure your image name starts with your docker login name (ex: ppresto)
```
docker login
docker images
docker push ppresto/mongo-ent:4.2
```

## Next Stes
Now that you have an image built, deploy it to your AKS cluster.  Go to one of the following 3 child directories to deploy your image.
* yaml-noPVC - use kubectl apply -f to deploy this service.
* yaml-PVC - use kubectl apply -f to deploy this service.
* yaml-PVC-withKMIP - use kubectl apply -f to deploy this service.

**Lifecycle Management with terraform**
If you want to manage your service configuration over time and always know exactly what state your K8s cluster is in then using the terraform kubernetes provider is an excellent way to do this.  It will deploy your services and manage the state over time so you can easily recover from any point in time.  Use this to deploy your mongodb service with kmip support.
* tf-PVC-withKMIP - use terraform (init, plan, apply)
```
cd tf-PVC-withKMIP/
terraform init
terraform apply -auto-approve
```