/* 
Invoke script like so:

/usr/lib/pig-0.9.2-SNAPSHOT/bin/pig -param marketplace=marketplace_mozilla_org_install marketplace_example.pig

*/
register 'akela-0.3-SNAPSHOT.jar'
register 'elephant-bird-2.2.0.jar'

SET pig.logfile marketplace-example.log;
SET default_parallel 4;
SET pig.tmpfilecompression true;
SET pig.tmpfilecompression.codec lzo;
SET mapred.compress.map.output true;
SET mapred.map.output.compression.codec org.apache.hadoop.io.compress.SnappyCodec;

raw = LOAD '/bagheera/$marketplace/*' USING com.twitter.elephantbird.pig.load.SequenceFileLoader (
    '-c com.twitter.elephantbird.pig.util.TextConverter', 
    '-c com.twitter.elephantbird.pig.util.TextConverter',
    '-skipEOFErrors'
) AS (key: chararray, json: chararray);
genmap = FOREACH raw GENERATE k,com.mozilla.pig.eval.json.JsonMap(json) AS json_map:map[];
records = FOREACH genmap GENERATE k,
                                  json_map#'app-domain' AS app_domain:chararray,
                                  json_map#'locale' AS locale:chararray,
                                  json_map#'src' AS src:chararray,
                                  json_map#'user-agent' AS user_agent:chararray;

/* Do fancy stuff here, write some UDFs to convert user_agent to relevant parts, or maybe persist to another DB */

/* For now just store flat structure as CSV */
STORE records INTO 'marketplace-alldays-csv' USING PigStorage(',');