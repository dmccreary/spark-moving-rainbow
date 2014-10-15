xquery version "1.0";
import module namespace s = "http://danmccreary.com/spark" at "../modules/spark.xqm";

let $title := 'New LED Strip Pattern'

let $new-pattern := request:get-parameter('new-pattern', '')
let $debug := xs:boolean(request:get-parameter('debug', 'true'))

(: check for valid values :)
return
if (not($new-pattern))
  then
     <error>
       <message>Error, the new-pattern is a required parameter"</message>
     </error>
     else (: continue :)
     
let $start-time := util:system-time()
let $change-pattern := s:new-pattern($new-pattern)

let $log := 
   if ($debug)
      then util:log-system-out(concat('new-pattern.xq?new-patter=', $new-pattern))
      else ()

return
<led-state-change>
  <new-pattern>{$new-pattern}</new-pattern>
  <spark-response>{$change-pattern}</spark-response>
  <response-time>{((util:system-time() - $start-time) div xs:dayTimeDuration('PT1S')) * 1000}</response-time>
</led-state-change>