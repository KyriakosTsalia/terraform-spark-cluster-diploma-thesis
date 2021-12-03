#!/bin/bash

# for local test deployments
if ! [[ -z ${RUNNING_LOCALLY} ]]; then
	export SPARK_WORKER_HOST=`hostname -i`
	export SPARK_LOCAL_IP=`hostname -i`
	export SPARK_PUBLIC_DNS=`hostname -i`
fi

cd $SPARK_HOME/bin && \
 	 $SPARK_HOME/sbin/../bin/spark-class org.apache.spark.deploy.worker.Worker $SPARK_MASTER \
	 --host $SPARK_WORKER_HOST \
	 --port $SPARK_WORKER_PORT \
	 --webui-port $SPARK_WORKER_WEBUI_PORT \
	 --cores $SPARK_WORKER_CORES \
	 --memory $SPARK_WORKER_MEMORY \
	 --properties-file $SPARK_HOME/conf/spark-defaults.conf
