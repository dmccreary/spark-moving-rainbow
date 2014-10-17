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

(: list all devices associated with this access-token :)
declare function s:get-device-info() as xs:string {
let $url :=
    concat($s:spark-url-prefix, $config:device-id, 
       '?access_token=', $config:access-token)
let $base-64-binary := httpclient:get(xs:anyURI($url), false(), <headers/>)
return util:base64-decode($base-64-binary/httpclient:body)
};

(: list all devices associated with this access-token :)
declare function s:devices() as xs:string {
let $headers :=
   <headers>
      <header name="Authorization" 
              value='Bearer {$config:access-token}'/>
   </headers>
let $url := xs:anyURI($s:spark-url-prefix)
let $base-64-binary := httpclient:get($url, false(), $headers)
return util:base64-decode($base-64-binary/httpclient:body)
};

(: get the value of a variable of the default device :)
declare function s:value($variable as xs:string) as xs:string {
let $headers :=
   <headers>
      <header name="Authorization" 
              value='Bearer {$config:access-token}'/>
   </headers>
let $url := xs:anyURI(concat($s:spark-url-prefix, $config:device-id, '/', $variable))
let $base-64-binary := httpclient:get($url, false(), $headers)
return util:base64-decode($base-64-binary/httpclient:body)
};

declare function s:device-status-json-string() as xs:string {
let $access-token := $config:access-token
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

declare function s:device-status-html() as element() {
let $access-token := $config:access-token
(: https://api.spark.io/v1/devices?access_token=ae47... :)
let $url := xs:anyURI(concat($s:spark-url-prefix, '?access_token=', $access-token))
let $base-64-binary := httpclient:get($url, false(), <headers/>) 
let $json-string := util:base64-decode($base-64-binary/httpclient:body)
let $xml-pairs := xqjson:parse-json($json-string)
let $xml-element-names := jpx:json-pairs-to-element($xml-pairs)
return
<table class="table table-striped table-bordered table-hover table-condensed">
   <thead>
     <tr>
        <th>Name</th>
        <th>Value</th>
     </tr>
   </thead>
    <tbody>{
    for $element in $xml-element-names/item/*
    return
       <tr>
          <th>{name($element)}</th>
          <td>{$element/text()}</td>
       </tr>
    }
    </tbody>
</table>
};

(: returns true() if the device is connected or false() otherwise :)
declare function s:device-connected() as xs:boolean {
let $access-token := $config:access-token
let $url := xs:anyURI(concat($s:spark-url-prefix, '?access_token=', $access-token))
let $base-64-binary := httpclient:get($url, false(), <headers/>) 
let $json-string := util:base64-decode($base-64-binary/httpclient:body)
let $xml-pairs := xqjson:parse-json($json-string)
let $xml-element-names := jpx:json-pairs-to-element($xml-pairs)
return
  if ($xml-element-names/item/connected = 'true')
     then true()
     else false()
};

(: execute a function with a specific name, no parameters 
   returns a simple JSON string:)
declare function s:function($function-name as xs:string) as xs:string {
let $url := xs:anyURI(concat($s:spark-url-prefix, $config:device-id, '/', $function-name))
let $headers :=
   <headers>
      <header name="Authorization" 
              value='Bearer {$config:access-token}'/>
   </headers>
let $result := util:base64-decode(httpclient:post($url, '', false(), $headers))
return $result
};

(: execute a function with a specific name, no parameters 
   returns a simple JSON string
   
   Call a function exposed by the core, 
   with arguments passed in request body, e.g., POST /v1/devices/0123456789abcdef01234567/brew
   
   int brew(String args)
   ...
   -d "args=202,230"
   :)
declare function s:function-params($function-name as xs:string, $params as xs:string) as xs:string {
let $url := xs:anyURI(concat($s:spark-url-prefix, $config:device-id, '/', $function-name))
let $content-length := string-length($params) + 2
let $content := concat('p=', $params)
let $headers :=
   <headers>
      <header name="Authorization" 
              value="Bearer {$config:access-token}"/>
      <header name="Content-Type" 
              value="application/x-www-form-urlencoded"/>
      <header name="Content-Length" 
              value="{$content-length}"/>
   </headers>
let $result := util:base64-decode(httpclient:post($url, $content, false(), $headers))
return $result
};

(: possible new patten values are: rainbow, red, white, dim etc. :)
declare function s:new-pattern($new-pattern-name as xs:string) as xs:string {
let $url := xs:anyURI(concat($s:spark-url-prefix, $config:device-id, '/changePat'))
let $content := concat('p=', $new-pattern-name)
let $content-length := string-length($content)
let $headers :=
   <headers>
      <header name="Authorization" 
              value='Bearer {$config:access-token}'/>
      <header name="Content-Type" 
              value="application/x-www-form-urlencoded"/>
      <header name="Content-Length" 
              value="{$content-length}"/>
   </headers>
let $result := util:base64-decode(httpclient:post($url, $content, false(), $headers))
return $result
};