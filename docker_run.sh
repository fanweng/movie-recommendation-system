#!/bin/bash
docker run --rm -itd -v $(pwd):/autocomplete -p 8080:80 goimg:0.1
