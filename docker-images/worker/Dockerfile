FROM ktsaliagkos/spark-base-image

# add script to start the spark master process
COPY start-worker.sh .

RUN chmod +x start-worker.sh

ENV SPARK_WORKER_PORT 44444
ENV SPARK_WORKER_WEBUI_PORT 8081
ENV SPARK_EXTERNAL_SHUFFLE_SERVICE_PORT 7337

# expose necessary ports
EXPOSE ${SPARK_WORKER_WEBUI_PORT}
EXPOSE 4040 4041 4042

ENTRYPOINT ["/bin/bash", "start-worker.sh"]
