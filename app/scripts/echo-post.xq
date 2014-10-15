xquery version "1.0";
import module namespace s = "http://danmccreary.com/spark" at "../modules/spark.xqm";

let $title := 'echo HTTP POST'

let $data := request:get-data()

let $log := util:log-system-out('running echo-post.xq')
let $log := util:log-system-out($data)
let $parameters :=
<parameters>
   {for $parameter in request:get-parameter-names()
   return
   <parameter>
      <name>{$parameter}</name>
      <value>{request:get-parameter($parameter, '')}</value>
   </parameter>
   }
   </parameters>
let $log := util:log-system-out($parameters)
return
<results>
  <data>{$data}</data>
  {$parameters}
</results>