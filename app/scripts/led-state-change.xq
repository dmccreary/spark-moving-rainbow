xquery version "1.0";
import module namespace s = "http://danmccreary.com/spark" at "../modules/spark.xqm";

let $title := 'LED State Change'

let $new-state := request:get-parameter('new-state', '')
let $debug := xs:boolean(request:get-parameter('debug', 'true'))

(: check for valid values :)
return
if (not($new-state = 'on' or $new-state = 'off'))
  then
     <error>
       <message>Error, the new state must be 'on' or 'off'.  Got "{$new-state}"</message>
     </error>
     else (: continue :)

let $change-state :=
   if ($new-state = 'on')
      then s:function('ledsOn')
      else s:function('ledsOff')

let $log := 
   if ($debug)
      then util:log-system-out(concat('led-state-change.xq?new-state=', $new-state))
      else ()

return
<led-state-change>
  <new-state>{$new-state}</new-state>
  <spark-response>{$change-state}</spark-response>
</led-state-change>