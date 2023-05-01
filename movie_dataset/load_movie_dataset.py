#!/usr/bin/env python3

import logging
import subprocess
import os
import glob
import zipfile
import csv
import json
import requests

logging.basicConfig(filename='load_dataset.log',
                    level=logging.INFO,
                    format='[%(asctime)s] %(filename)s Line:%(lineno)d %(levelname)s - %(message)s',
                    filemode='w'
)

ENV_WORKSPACE = os.environ.copy();
WORKSPACE = os.getcwd();
KAGGLE_PATH = '/root/.local/bin/kaggle'

# remove residual files if exist
residual_file_types = ('*.zip', '*.csv', '*.json');
residual_files = []
for ftype in residual_file_types:
    residual_files += glob.glob(ftype)
if len(residual_files) != 0:
    for f in residual_files:
        os.remove(f)
    logging.info('Clean up the residual files: ' + str(residual_files))

# Download movie dataset from Kaggle
kaggle_dl_cmd = '{} datasets download -d harshitshankhdhar/imdb-dataset-of-top-1000-movies-and-tv-shows -p {}'.format(KAGGLE_PATH, WORKSPACE)
result = subprocess.run(kaggle_dl_cmd, capture_output=True, shell=True, text=True, env=ENV_WORKSPACE)
if result.returncode == 0:
    logging.info(result.stdout)
else:
    logging.error(result.stderr)

# Unzip the dataset
dataset_zip = glob.glob('*.zip')
with zipfile.ZipFile(dataset_zip[0], 'r') as zip_ref:
    zip_ref.extractall(WORKSPACE)
dataset_csv = glob.glob('*.csv')
logging.info('Unzipped the {} to {}'.format(dataset_zip[0], dataset_csv[0]))

# Parse the CSV dataset to JSON format
dataset_json = 'data.json'
bulk_data = []
index_name = 'movie_index'
# read CSV file and append rows to list
with open(dataset_csv[0], 'r') as f:
    csv_reader = csv.DictReader(f)
    for row in csv_reader:
        index_data = {}
        index_data['index'] = { 'index' : {'_index': index_name, '_type': '_doc'} }
        index_data['data'] = row
        bulk_data.append(index_data)
# write JSON data to file
with open(dataset_json, 'w') as f:
    for data in bulk_data:
        json.dump(data['index'], f)
        f.write('\n')
        json.dump(data['data'], f)
        f.write('\n')
logging.info('JSON file {} for bulk ingestion is ready'.format(dataset_json))

# # Check connection to the load balancer
host_ip = os.environ['HOST_IP']
load_balancer_port = 8003
elasticsearch_port = 8001
url = 'http://{}:{}'.format(host_ip, elasticsearch_port)

connection_open = False
curl_cmd = ["curl", "-Is", url]
try:
    result = subprocess.check_output(curl_cmd, stderr=subprocess.STDOUT)
    connection_open = True
    logging.info('Connection to {} is open'.format(url))
except subprocess.CalledProcessError as e:
    connection_open = False
    logging.error('Connection to {} failed'.format(url))

# Bulk ingest data to the database
load_succeeded = False
index_url = url + '/' + index_name
if (connection_open):
    api_bulk = index_url + '/_bulk?pretty'
    headers = {'Content-Type': 'application/json'}
    with open(dataset_json, 'r') as f:
        data = f.read()
    response = requests.post(api_bulk, headers=headers, data=data)
    print(response.content)
    logging.info('Bulk ingestion to database at {} is done'.format(index_url))

# # Test a search request
# host_ip = os.environ['HOST_IP']
# load_balancer_port = 8003
# elasticsearch_port = 8001
# url = 'http://{}:{}'.format(host_ip, elasticsearch_port)
# index_name = 'movie_index'
# index_url = url + '/' + index_name

# api_search = index_url + '/_search?q='
# search_string = 'gump'
# request = api_search + search_string

# response = requests.get(request)
# print(response.content)
