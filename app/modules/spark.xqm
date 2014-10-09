xquery version "3.0";

(: functions to aid in calling a spark.io device using the REST API :)

module namespace s = "http://danmccreary.com/spark";
(:
import module namespace s = "http://danmccreary.com/spark" at "../modules/spark.xqm";
:)
import module namespace config = "http://danmccreary.com/config" at "config.xqm";
import module namespace xqjson="http://xqilla.sourceforge.net/lib/xqjson";
import module namespace jpx = "http://danmccreary.com/jpx" at "../modules/jpx.xqm";

(:
curl https://api.spark.io/v1/devices/0123456789abcdef/led \
  -d access_token=123412341234 \
  -d params=l1,HIGH
:)

declare variable $s:spark-url-prefix := 'https://api.spark.io/v1/devices/';

(: send a param and values using the REST API.  We assume that the the $config file has
   both the device and the access-token :)
declare function s:send($name as xs:string, $params as xs:string, $config as element()) as xs:string {
let $device-id := $config/device-id/text()
let $access-token := $config/access-token/text()
return concat($s:spark-url-prefix, $name, ' -d access_token=', $access-token, ' -d params=',$params)
};

declare function s:device-status-json-string() as xs:string {
let $access-token := $config:access-token
(: https://api.spark.io/v1/devices?access_token=ae47... :)
let $url := xs:anyURI(concat($s:spark-url-prefix, '?access_token=', $access-token))
let $base-64-binary := httpclient:get($url, false(), <headers/>) 
return util:base64-decode($base-64-binary/httpclient:body)
};

declare function s:device-status-xml-pairs() as element() {
let $access-token := $config:access-token
(: https://api.spark.io/v1/devices?access_token=ae47... :)
let $url := xs:anyURI(concat($s:spark-url-prefix, '?access_token=', $access-token))
let $base-64-binary := httpclient:get($url, false(), <headers/>) 
let $json-string := util:base64-decode($base-64-binary/httpclient:body)
return
       xqjson:parse-json($json-string)
};


declare function s:device-status-xml() as element() {
let $access-token := $config:access-token
(: https://api.spark.io/v1/devices?access_token=ae47... :)
let $url := xs:anyURI(concat($s:spark-url-prefix, '?access_token=', $access-token))
let $base-64-binary := httpclient:get($url, false(), <headers/>) 
let $json-string := util:base64-decode($base-64-binary/httpclient:body)
let $xml-pairs := xqjson:parse-json($json-string)
return
   jpx:json-pairs-to-element($xml-pairs)
};