#!/bin/bash

. $(dirname $0)/daily-marketplace-setvars.sh

cd $ETL_HOME
LOG=$ETL_HOME/logs/daily-marketplace-cron.log

${PIG_HOME}/bin/pig -param date=$YESTERDAY -param marketplace=$MARKETPLACE $ETL_HOME/marketplace_daily_aggregates.pig > $LOG 2>&1
MARKET_RESULT=$?
if [ "$MARKET_RESULT" -eq "0" ]; then
   echo "Marketplace Stats export succeeded for $YESTERDAY"
else
   echo "ERROR: Marketplace Stats Export failed (code $MARKET_RESULT) for $YESTERDAY.  Check $LOG for more details."
   exit 2
fi

hadoop fs -getmerge webapp_stats_date-$YESTERDAY $ETL_HOME/marketplace/webapp_stats_date-$YESTERDAY.txt >> $LOG 2>&1
scp $ETL_HOME/marketplace/webapp_stats_date-$YESTERDAY.txt ${PUB_SERVER}:${PUB_PATH}/
if [ ! "$?" -eq "0" ]; then
   echo "ERROR: Failed to transfer webapp_stats_date-$YESTERDAY.txt to $PUB_SERVER"
fi

hadoop fs -getmerge webapp_stats_device-$YESTERDAY $ETL_HOME/marketplace/webapp_stats_device-$YESTERDAY.txt >> $LOG 2>&1
scp $ETL_HOME/marketplace/webapp_stats_device-$YESTERDAY.txt ${PUB_SERVER}:${PUB_PATH}/
if [ ! "$?" -eq "0" ]; then
   echo "ERROR: Failed to transfer webapp_stats_device-$YESTERDAY.txt to $PUB_SERVER"
fi

hadoop fs -getmerge webapp_stats_source-$YESTERDAY $ETL_HOME/marketplace/webapp_stats_source-$YESTERDAY.txt >> $LOG 2>&1
scp $ETL_HOME/marketplace/webapp_stats_source-$YESTERDAY.txt ${PUB_SERVER}:${PUB_PATH}/
if [ ! "$?" -eq "0" ]; then
   echo "ERROR: Failed to transfer webapp_stats_source-$YESTERDAY.txt to $PUB_SERVER"
fi
