#!/bin/bash


echo "Starting Spark shell..."

export DRIVER_NAME=spark-shell
if [ ! -z "$SPARK_DRIVER_NAME" ]
then 
    export DRIVER_NAME=$SPARK_DRIVER_NAME
fi

export DRIVER_PORT=29613
if [ ! -z "$SPARK_DRIVER_PORT" ]  
then                             
    export DRIVER_PORT=$SPARK_DRIVER_PORT
fi    

export SA=spark-sa-dr
if [ ! -z "$SPARK_DRIVER_SA" ]                                       
then                                                                                           
    export SA=$SPARK_DRIVER_SA
fi    

export NAMESPACE=default
if [ ! -z "$NAMESPACE" ]                                                                  
then  
    export NAMESPACE=$NAMESPACE
fi

CASSANDRA_CONNECT_CONF="--conf spark.cassandra.connection.host=192.168.105.170"
if [ ! -z $CASSANDRA_HOST ]
then
    CASSANDRA_CONNECT_CONF="--conf spark.cassandra.connection.host=$CASSANDRA_HOST"
fi

export K8S_CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
export K8S_TOKEN=/var/run/secrets/kubernetes.io/serviceaccount/token
export DOCKER_IMAGE=sontivr/spark-2.4.0-bin-hadoop2.7:latest

kubectl expose deployment $DRIVER_NAME --port=$DRIVER_PORT --type=ClusterIP --cluster-ip=None

/opt/spark/bin/spark-shell --name spark-shell  \
                --master k8s://https://kubernetes.default.svc.cluster.local:443  \
                --deploy-mode client  \
                --conf spark.kubernetes.authenticate.caCertFile=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt  \
                --conf spark.kubernetes.authenticate.oauthTokenFile=/var/run/secrets/kubernetes.io/serviceaccount/token  \
                --conf spark.kubernetes.authenticate.driver.serviceAccountName=$SA  \
                --conf spark.kubernetes.namespace=$NAMESPACE  \
                --conf spark.executor.instances=3  \
                --conf spark.kubernetes.container.image=$DOCKER_IMAGE  \
                --conf spark.driver.host=$DRIVER_NAME.$NAMESPACE.svc.cluster.local  \
                --conf spark.driver.port=$DRIVER_PORT  \
		$CASSANDRA_CONNECT_CONF \
		--packages datastax:spark-cassandra-connector:2.4.0-s_2.11 

echo "Exiting Spark shell ..."

