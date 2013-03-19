#!/bin/bash

. $(dirname $0)/daily-marketplace-setvars.sh

cd $ETL_HOME
${PIG_HOME}/bin/pig -param date=$YESTERDAY -param marketplace=$MARKETPLACE $ETL_HOME/marketplace_daily_aggregates.pig

hadoop fs -getmerge webapp_stats_date-$YESTERDAY $ETL_HOME/marketplace/webapp_stats_date-$YESTERDAY.txt
scp $ETL_HOME/marketplace/webapp_stats_date-$YESTERDAY.txt ${PUB_SERVER}:${PUB_PATH}/
hadoop fs -getmerge webapp_stats_device-$YESTERDAY $ETL_HOME/marketplace/webapp_stats_device-$YESTERDAY.txt
scp $ETL_HOME/marketplace/webapp_stats_device-$YESTERDAY.txt ${PUB_SERVER}:${PUB_PATH}/
hadoop fs -getmerge webapp_stats_source-$YESTERDAY $ETL_HOME/marketplace/webapp_stats_source-$YESTERDAY.txt
scp $ETL_HOME/marketplace/webapp_stats_source-$YESTERDAY.txt ${PUB_SERVER}:${PUB_PATH}/
