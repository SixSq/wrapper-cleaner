#!/bin/bash 

set -x

docker events --filter 'event=die' --filter "container=${PARENT}" | while read line
do     
  echo "PARENT DIED $PARENT"
  echo "Removing the following containers: $CHILD"
  docker rm -f $CHILD || echo "cannot find container $CHILD"

  echo "Removing the following Docker Volumes: $VOLUMES"
  docker volume rm $VOLUMES

  docker rm -f $(hostname)
done
