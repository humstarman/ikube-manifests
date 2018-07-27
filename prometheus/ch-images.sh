#!/bin/bash

[ -f manifests-all.yaml ] && rm -f manifests-all.yaml
[ -f manifests-all.yaml ] || touch manifests-all.yaml

cat manifests-all.yaml.bak | while read LINE; do
  IMAGE=$(echo $LINE | grep "image:")
  if [ -n "$IMAGE" ]; then
    echo $IMAGE
  else
    echo $LINE >> manifests-all.yaml
  fi
done
