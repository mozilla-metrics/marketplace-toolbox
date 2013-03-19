#!/bin/bash

export JAVA_HOME=/usr/lib/jvm/java-sun
PIG_HOME=/usr/lib/pig
ETL_HOME=/home/etl

## Default to running for yesterday.
YESTERDAY="`date +%Y-%m-%d --date="1 day ago"`"

## If a parameter was passed in, use that for the target day:
if [ ! -z "$1" ]; then
  YESTERDAY=$(date -d "$1" +%Y-%m-%d)
fi

MARKETPLACE=marketplace_example
PUB_SERVER=example.mozilla.com
PUB_PATH=/var/www
