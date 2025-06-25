#!/bin/bash

echo "Stopping...." 
podman stop noip

echo "Dropping...."
podman rm noip

echo "Creating container"
docker run -d --env-file noip.env --name noip ghcr.io/noipcom/noip-duc:latest

sleep 1

echo "Checking...."
podman inspect --format '{{.State.Status}}' noip 

podman logs noip

exit 0
