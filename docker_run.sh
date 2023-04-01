#!/bin/bash
docker run --rm -itd -v $(pwd)/autocomplete_server:/autocomplete -p 8080:80 --name autocomplete goimg:0.2
docker run --rm -itd -v $(pwd)/reverse_index_server/data:/usr/share/elasticsearch/data -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" --name reverse_index esimg:0.1
