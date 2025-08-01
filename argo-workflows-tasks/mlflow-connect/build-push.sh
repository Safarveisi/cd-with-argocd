#!/bin/bash

set -e

docker build --tag ciaa/mlflow-connect:latest . > build.log 2>&1

docker push ciaa/mlflow-connect:latest
