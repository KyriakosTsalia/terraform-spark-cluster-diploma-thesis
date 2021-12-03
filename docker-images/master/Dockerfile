FROM ktsaliagkos/spark-base-image

# add script to start the spark master process
COPY start-master.sh .

RUN chmod +x start-master.sh

ENV SPARK_MASTER_PORT 7077
ENV SPARK_MASTER_WEBUI_PORT 8080
ENV SPARK_MASTER_REST_PORT 6066

# expose necessary ports
EXPOSE ${SPARK_MASTER_WEBUI_PORT}
EXPOSE ${SPARK_MASTER_REST_PORT}

ENTRYPOINT ["/bin/bash", "start-master.sh"]
