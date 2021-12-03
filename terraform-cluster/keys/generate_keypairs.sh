#!/bin/bash

if [ $# -eq 0 ]
  then
    echo "Correct usage: ./create_keypairs.sh \${NUM_OF_WORKERS}"
    exit 1
fi

NUM_OF_WORKERS=$1

for num in $(seq -f "%02g" 0 $(($NUM_OF_WORKERS - 1)))
do
  ssh-keygen -f spark-worker-${num}-key
done

ssh-keygen -f spark-master-key
ssh-keygen -f spark-gateway-key
ssh-keygen -f prom-graf-key

echo "Done."