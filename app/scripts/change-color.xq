xquery version "1.0";
import module namespace s = "http://danmccreary.com/spark" at "../modules/spark.xqm";

let $title := 'Change Color'

let $color := request:get-parameter('color', '')
let $debug := xs:boolean(request:get-parameter('debug', 'true'))

(: check for valid values :)
return
if (not($color))
  then
     <error>
       <message>Error, color is a required parameter"</message>
     </error>
     else (: continue :)

let $run := s:function-value('set-color', $color)

let $log := 
   if ($debug)
      then util:log-system-out(concat('change-color.xq?color=', $color))
      else ()

return
<change-color>
  <new-color>{$color}</new-color>
  <spark-response>{$change-state}</spark-response>
</change-color>