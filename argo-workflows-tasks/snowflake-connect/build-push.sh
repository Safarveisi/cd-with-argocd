#!/bin/bash

set -e

docker build --tag ciaa/snowflake-connect:latest . > build.log 2>&1

docker push ciaa/snowflake-connect:latest
