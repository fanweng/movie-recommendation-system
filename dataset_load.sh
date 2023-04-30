#!/bin/bash

# Need to pass the host IP address to the container, so it can connect to other containers
HOST_IP=`hostname -I | cut -d ' ' -f1`
docker run --rm -itd -e HOST_IP=$HOST_IP -v $(pwd)/movie_dataset:/movie_dataset -p 8004:80 --name movie_dataset dataimg:0.1
