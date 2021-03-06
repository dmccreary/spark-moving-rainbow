xquery version "3.0";

import module namespace config = "http://danmccreary.com/config" at "../modules/config.xqm";

import module namespace s = "http://danmccreary.com/spark" at "../modules/spark.xqm";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:media-type "application/json";
let $config := $config:config

let $title := 'Device Status XML Pairs'

return s:device-status-xml-pairs()