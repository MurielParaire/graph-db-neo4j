# How to deploy to kube

## Prerequisites

- have a kubernetes cluster available
- have access to kubectl

## Install Spark Operator

=> install spark operator by following the [official guidelines](https://www.kubeflow.org/docs/components/spark-operator/getting-started/)

=> you can test the installation by testing the [spark-pi.yaml](https://github.com/kubeflow/spark-operator/blob/master/examples/spark-pi.yaml) test file (scroll down on their gettign started page to find the commands)


## Use MinIO

=> install MinIO on kubernetes

=> you should now have a service called minio in a namespace minio.
You can forward it to be able to access the Web Interface:
```
kubectl port-forward svc/minio 9000:9000 -n minio
kubectl port-forward svc/minio-console 9001:9001 -n minio
```

=> access it and create a *public* bucket and put 2 documents there:
- users.csv
- TestUser.jar (you can generate the jar file with `sbt package` => it will be in target/scala-2.12)

You also need to create a new user and create an access key for it.
You'll need to replace these two values:
```
    "spark.hadoop.fs.s3a.access.key": "<access key>" //replace with your access key
    "spark.hadoop.fs.s3a.secret.key": "<secret key>" //replace with your secret key
```


## Deploy to kube using MinIO

=> create local docker image (here we will call it spark)
```
docker build -t spark:v1.0 . -f Dockerfile.yaml  --no-cache
```

=> import that image into our cluster (that we called nosql)
```
k3d image import spark:v1.0 -c nosql
```

=> replace the access and secret key in [usertest.yaml](./usertest.yaml)

=> deploy the application with 
```
kubectl apply -f day2/spark/kube/usertest.yaml
```

# deploy MiNIO Streaming

=> you will need the docker image created before
=> as well as a Kubernetes with MinIO and Spark-operator

=> deploy the application with 
```
kubectl apply -f day2/spark/kube/spark_minio_streaming.yaml
```

=> replace the access and secret key in [spark_minio_streaming.yaml](./spark_minio_streaming.yaml)