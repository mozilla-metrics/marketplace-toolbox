register 'akela-0.3-SNAPSHOT.jar'
register 'elephant-bird-2.2.0.jar'
register 'wonderdog-1.0-SNAPSHOT.jar'
register './elasticsearch/lib/*.jar'

SET pig.logfile marketplace-es.log;
SET default_parallel 4;
SET pig.tmpfilecompression true;
SET pig.tmpfilecompression.codec lzo;
SET mapred.compress.map.output true;
SET mapred.map.output.compression.codec org.apache.hadoop.io.compress.SnappyCodec;

%default INDEX '$marketplace'
%default OBJ 'data'

raw = LOAD '/bagheera/$marketplace/*' USING com.twitter.elephantbird.pig.load.SequenceFileLoader (
    '-c com.twitter.elephantbird.pig.util.TextConverter', 
    '-c com.twitter.elephantbird.pig.util.TextConverter',
    '-skipEOFErrors'
) AS (key: chararray, json: chararray);
json_only = FOREACH raw GENERATE json;

/* To play with marketplace data in more detail make a map of it 
genmap = FOREACH raw GENERATE k,com.mozilla.pig.eval.json.JsonMap(json) AS json_map:map[];
*/

STORE json_only INTO 'es://$INDEX/$OBJ?json=true&size=1000&tasks=4' 
                USING com.infochimps.elasticsearch.pig.ElasticSearchStorage('/home/xstevens/elasticsearch/elasticsearch-telemetry.yml',
                                                                            '/home/xstevens/elasticsearch/plugins');