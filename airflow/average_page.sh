#!/bin/bash

echo "Starting Spark Job"
cd ~spark/batch_averages
spark-submit --class site_batch --master spark://ip-10-0-0-8:7077 --packages datastax:spark-cassandra-connector:2.3.0-s_2.11 target/scala-2.11/site_batch_2.11-1.0.jar
echo "Spark Job Completed"