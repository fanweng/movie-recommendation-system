#!/bin/bash

# Make sure Kaggle API is installed
if !( command -v kaggle > /dev/null 2>&1 ); then
    echo "Please refer to README and install the Kaggle API first, exit.."
else
    echo "$( kaggle --version ) is deteced on this machine..."
fi

TOP_PATH=$( dirname "$( realpath -s "$0" )" )
WORKSPACE_NAME=dataset_tmp_workspace
WORKSPACE_DIR=$TOP_PATH/$WORKSPACE_NAME

echo "Creating a temporary workspace: $WORKSPACE_DIR/"
mkdir -p $WORKSPACE_DIR

# Download a movie dataset from Kaggle
kaggle datasets download -d harshitshankhdhar/imdb-dataset-of-top-1000-movies-and-tv-shows -p $WORKSPACE_DIR

DATASET_ZIP_NAME=$( basename "$( find $WORKSPACE_DIR -type f -name "*.zip" )" )
DATASET_ZIP_PATH=$WORKSPACE_DIR/$DATASET_ZIP_NAME

echo "Unzip the downloaeded dataset: $DATASET_ZIP_NAME"
if !( command -v unzip > /dev/null 2>&1 ); then
    echo "Unzip tool does not exist, installing..."
    sudo apt-get install unzip
else
    echo "Unzipping..."
fi
unzip $DATASET_ZIP_PATH -d $WORKSPACE_DIR

DATASET_CSV_NAME=$( basename "$( find $WORKSPACE_DIR -type f -name "*.csv" )" )
DATASET_CSV_PATH=$WORKSPACE_DIR/$DATASET_CSV_NAME

echo "Process the dataset: $DATASET_CSV_NAME"

echo "Cleaning up the temporary workspace: $WORKSPACE_DIR/"
rm -rf $WORKSPACE_DIR
