xquery version "3.0";

import module namespace config = "http://danmccreary.com/config" at "../modules/config.xqm";
import module namespace style = "http://danmccreary.com/style" at "../modules/style.xqm";

import module namespace s = "http://danmccreary.com/spark" at "../modules/spark.xqm";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:media-type "application/json";
let $config := $config:config

let $title := 'Device Status'

let $start-time := util:system-time()
let $html-table := s:device-status-html()

let $content :=
<div class="content">
   <div class="row">
   <div class="col-md-4">
   {$html-table}
   </div>
   <div class="col-md-3">
   Runtime = {((util:system-time() - $start-time) div xs:dayTimeDuration('PT1S')) * 1000} milliseconds
   </div>
   </div>
</div>

return style:assemble-page($title, $content)