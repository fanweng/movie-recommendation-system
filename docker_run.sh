#!/bin/bash
docker run --rm -itd -v $(pwd)/autocomplete_server:/autocomplete -p 8000:80 --name autocomplete goimg:0.2
docker run --rm -itd -v $(pwd)/reverse_index_server/data:/usr/share/elasticsearch/data -p 8001:9200 -p 8002:9300 -e "discovery.type=single-node" --name reverse_index esimg:0.1
docker run --rm -itd -v $(pwd)/load_balancer:/movie_recommendation_logs -v $(pwd)/load_balancer/nginx.conf:/etc/nginx/nginx.conf:ro -p 8003:80 --name load_balancer nginximg:0.1
