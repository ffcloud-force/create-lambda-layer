#!/bin/bash

# Set the directory where the Dockerfile and requirements.txt are located
DIRECTORY="$(pwd)"

# Change it as per your requirement
LAYER_NAME="requests-layer"

# Build the Docker image with platform specification for M4 Mac
docker build --platform linux/amd64 -t lambda-layer "$DIRECTORY"

# Run the Docker container to create the layer (with --rm for auto cleanup)
docker run --rm --platform linux/amd64 -v "$DIRECTORY:/app" lambda-layer

# create layers directory, if not created.
mkdir -p layers

# Move the zip file in layers directory.
mv "$DIRECTORY/$LAYER_NAME.zip" "$DIRECTORY/layers/$LAYER_NAME.zip"

# Cleanup: remove the Docker image
docker rmi --force lambda-layer