#!/bin/bash 

set -x

docker events --filter 'event=die' --filter "container=${PARENT}" | while read line
do     
  echo "PARENT DIED $PARENT"
  docker rm -f $CHILD || echo "cannot find container $CHILD"
  docker rm -f $(hostname)
done
