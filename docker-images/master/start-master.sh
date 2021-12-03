#!/bin/bash

# for local test deployments
if ! [[ -z ${RUNNING_LOCALLY} ]]; then
	export SPARK_MASTER_HOST=`hostname -i`
	export SPARK_LOCAL_IP=`hostname -i`
	export SPARK_PUBLIC_DNS=`hostname -i`
fi

cd $SPARK_HOME/bin && \
	 $SPARK_HOME/sbin/../bin/spark-class org.apache.spark.deploy.master.Master \
	 --host $SPARK_MASTER_HOST \
	 --port $SPARK_MASTER_PORT \
	 --webui-port $SPARK_MASTER_WEBUI_PORT \
	 --properties-file $SPARK_HOME/conf/spark-defaults.conf

