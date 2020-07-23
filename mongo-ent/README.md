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

### Next Stes
Now that you have an image built you can deploy it to your AKS cluster.  Go to one of the following 3 child directories to deploy your image using the quickstart that has no persistant storage, the standalone instance with PVC, or for a more advanced setup use Vault Enterprises KMIP support for FDE.  