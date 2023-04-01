FROM ubuntu:lunar-20230301
RUN apt update && apt install -y vim golang
VOLUME /autocomplete
WORKDIR /autocomplete
CMD go run hello.go
