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

## deploy MiNIO Streaming

=> you will need the docker image created before
=> as well as a Kubernetes with MinIO and Spark-operator

=> deploy the application with 
```
kubectl apply -f day2/spark/kube/spark_minio_streaming.yaml
```

=> replace the access and secret key in [spark_minio_streaming.yaml](./spark_minio_streaming.yaml)


## Deploy Kafka

We will be using the [strimzi kafka operator](https://artifacthub.io/packages/helm/strimzi/strimzi-kafka-operator).

```
helm repo add strimzi https://strimzi.io/charts
helm repo update
helm install my-strimzi-kafka-operator strimzi/strimzi-kafka-operator --version 0.45.0
```

download and apply [kafka-persistent-single.yaml](https://github.com/strimzi/strimzi-kafka-operator/blob/main/examples/kafka/kafka-persistent-single.yaml)
```
kubectl apply -f kafka-persistent-single.yaml
```

**Configure kafka**
create a kafka topic:
```
kubectl --namespace default exec -it my-cluster-kafka-0 -c kafka -- bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic  cats
```

In this case, I called the topic cats so it will listen on it. To create new messages, you can use:
```
kubectl --namespace default exec -it my-cluster-kafka-0 -c kafka -- bin/kafka-console-producer.sh --bootstrap-server localhost:9092 --topic  cats
```
and write any message in the new command line.