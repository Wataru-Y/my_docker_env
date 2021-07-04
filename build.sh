#!/bin/sh

TAG=cuda11.3-python3.8

if [ $# -eq 0 ]; then
    docker build . -t wataru-y/dl_remote:${TAG}
else
    docker build . -f Dockerfile.$@ -t wataru-y/dl_remote:$@
fi