import module namespace config = "http://danmccreary.com/config" at "../modules/config.xqm";

import module namespace s = "http://danmccreary.com/spark" at "../modules/spark.xqm";

(: we assume a single device with the device ID and access key in the config file :)
declare function local:post() as xs:string {
let $url := xs:anyURI( concat($s:spark-url-prefix, $config:device-id, '/ledsOn') )
let $headers :=
   <headers>
      <header name="Authorization" 
              value='Bearer {$config:access-token}'/>
   </headers>
let $result := util:base64-decode(httpclient:post($url, '', false(), $headers))
return $result
};

let $start-time := util:system-time()
let $do-post := local:post()

return
<results>
   <config>{$config:config}</config>
   <api-prefix>{$s:spark-url-prefix}</api-prefix>
   <put-url>{concat($s:spark-url-prefix, $config:device-id, '/ledsOn')}</put-url>
   <result>{$do-post}</result>
   <runtime-ms>{((util:system-time() - $start-time) div xs:dayTimeDuration('PT1S')) * 1000}</runtime-ms>
</results>