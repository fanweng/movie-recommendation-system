#!/bin/bash

AUTOCOMPLETE_PORT=8000
REVERSE_INDEX_PORT1=8001
REVERSE_INDEX_PORT2=8002
LOAD_BALANCER_PORT=8003
HOST_IP=`hostname -I | cut -d ' ' -f1`

docker run --rm -itd -v $(pwd)/autocomplete_server:/autocomplete -p $AUTOCOMPLETE_PORT:80 --name autocomplete goimg:0.2

docker run --rm -itd -v $(pwd)/reverse_index_server/data:/usr/share/elasticsearch/data -p $REVERSE_INDEX_PORT1:9200 -p $REVERSE_INDEX_PORT2:9300 -e "discovery.type=single-node" --name reverse_index esimg:0.1

# All occurrences of {{HOST_IP}} in the template will be replacedd with current host IP value
sed "s/{{HOST_IP}}/$HOST_IP/g" ./load_balancer/nginx.conf.tmpl > ./load_balancer/nginx.conf

docker run --rm -itd -v $(pwd)/load_balancer:/movie_recommendation_logs -v $(pwd)/load_balancer/nginx.conf:/etc/nginx/nginx.conf:ro -p $LOAD_BALANCER_PORT:80 --name load_balancer nginximg:0.1
