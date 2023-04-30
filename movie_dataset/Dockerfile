FROM ubuntu:latest

ENV PATH="$PATH:~/.local/bin"
ENV KAGGLE_USERNAME=<your_kaggle_username>
ENV KAGGLE_KEY=<your_kaggle_api_key>

RUN apt update && \
    apt install -y \
    unzip \
    curl \
    python3 \
    python3-pip

RUN pip3 install --user kaggle

VOLUME /movie_dataset
WORKDIR /movie_dataset

CMD python3 load_movie_dataset.py
CMD ["bash"]
