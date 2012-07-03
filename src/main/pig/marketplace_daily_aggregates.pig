register 'akela-0.3-SNAPSHOT.jar'
register 'elephant-bird-2.2.0.jar'

SET pig.logfile marketplace_daily_aggregates.log;
/* SET default_parallel 4; */
SET pig.tmpfilecompression true;
SET pig.tmpfilecompression.codec lzo;
SET mapred.compress.map.output true;
SET mapred.map.output.compression.codec org.apache.hadoop.io.compress.SnappyCodec;

raw = LOAD '/bagheera/$marketplace/$date' USING com.twitter.elephantbird.pig.load.SequenceFileLoader (
    '-c com.twitter.elephantbird.pig.util.TextConverter', 
    '-c com.twitter.elephantbird.pig.util.TextConverter',
    '-skipEOFErrors'
) AS (k: chararray, json: chararray);

genmap = FOREACH raw GENERATE com.mozilla.pig.eval.json.JsonMap(json) AS json_map:map[];
records = FOREACH genmap GENERATE (chararray)json_map#'app-domain' AS app_domain:chararray,
                                  (chararray)json_map#'locale' AS locale:chararray,
                                  (chararray)json_map#'src' AS src:chararray,
                                  (int)json_map#'app-id' AS app_id:int,
                                  (chararray)json_map#'user-agent' AS user_agent:chararray;
                                  
grpd_by_app = GROUP records BY (app_domain,app_id);
counts_by_app = FOREACH grpd_by_app GENERATE FLATTEN(group), COUNT(records);
STORE counts_by_app INTO 'webapp_stats_date-$date';

grpd_by_device = GROUP records BY (app_id,user_agent);
counts_by_device = FOREACH grpd_by_device GENERATE FLATTEN(group), COUNT(records);
STORE counts_by_device INTO 'webapp_stats_device-$date';

grpd_by_source = GROUP records BY (app_id,src);
counts_by_source = FOREACH grpd_by_source GENERATE FLATTEN(group), COUNT(records);
STORE counts_by_source INTO 'webapp_stats_source-$date';