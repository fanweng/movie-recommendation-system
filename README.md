# Movie Recommendation System

## 1. Start the System

### Create docker images

Go to server directories and create docker images for them respectively.
```
$ cd ./autocomplete_server
$ docker build -f Dockerfile -t goimg:0.2 .

$ cd ./everse_index_server
$ docker build -f Dockerfile -t esimg:0.1 .

$ cd ./load_balancer
$ docker build -f Dockerfile -t nginximg:0.1 .
```

### Run docker containers

```
$ ./docker_run.sh
```

+ Autocomplete server: `http://localhost:8000`
+ Reverse index server: `http://localhost:8001` and `http://localhost:8002`
+ Nginx load balancer: `http://localhost:8003`

### Stop docker containers

```
$ ./docker_stop.sh
```

## 2. Load Movie Dataset to Reverse Index Server

### Create docker images

Go to `movie_dataset` directory and change the `KAGGLE_USERNAME`/`KAGGLE_KEY` to your own Kaggle credential. Then create the docker image `dataimg:0.1`.
```
$ cd ./movie_dataset
$ docker build -f Dockerfile -t dataimg:0.1 .
```

### Run docker container for dataset loading

```
$ ./dataset_load.sh
```

### Test a search request

The access point for a user should always be the **load balancer**, not other two servers. [`nginx.conf`](load_balancer/nginx.conf) defines the endpoint for search is `/search` which will be routed to reverse index server.

Thus in the Chrome browser, we can request using the following URL with an input string:
```
http://localhost:8003/search?q=your_input
```

In the local host terminal, use `curl` command to send a request:
```
$ curl -X GET "http://localhost:8003/search?q=your_input"
```

### Dependencies

1. [IMDB Movie Dataset](https://www.kaggle.com/datasets/harshitshankhdhar/imdb-dataset-of-top-1000-movies-and-tv-shows)

2. Kaggle API: [https://github.com/Kaggle/kaggle-api](https://github.com/Kaggle/kaggle-api)
