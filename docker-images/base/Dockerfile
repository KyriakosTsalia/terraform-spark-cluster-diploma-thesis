FROM ubuntu:20.04

RUN apt-get update && apt-get -y upgrade

# install java and other basic functionalities
RUN apt-get install --no-install-recommends -y sudo wget tar vim openjdk-8-jdk

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

WORKDIR /root

# install scala
RUN wget https://downloads.lightbend.com/scala/2.12.12/scala-2.12.12.tgz && \
		tar -xvzf scala-2.12.12.tgz && \
		rm scala-2.12.12.tgz

ENV SCALA_HOME /root/scala-2.12.12
ENV PATH $PATH:$SCALA_HOME/bin

# install spark
RUN wget https://downloads.apache.org/spark/spark-3.0.1/spark-3.0.1-bin-hadoop3.2.tgz && \
		tar -xvzf spark-3.0.1-bin-hadoop3.2.tgz && \
		mv spark-3.0.1-bin-hadoop3.2 spark && \
		rm spark-3.0.1-bin-hadoop3.2.tgz

ENV SPARK_HOME /root/spark

# configure aws s3 access, more: https://notadatascientist.com/running-apache-spark-and-s3-locally/
# install hadoop aws
RUN wget https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.2.0/hadoop-aws-3.2.0.jar \
		-P ./spark/jars/

# install aws java sdk
RUN wget https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.11.375/aws-java-sdk-bundle-1.11.375.jar \
		-P ./spark/jars/

# clean out the cache once the packages are installed
RUN apt-get clean

# copy custom spark confuguration file
COPY spark-defaults.conf ./spark/conf/

# copy custom spark metrics file
COPY metrics.properties ./spark/conf/