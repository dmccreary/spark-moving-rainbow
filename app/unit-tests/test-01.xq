import module namespace config = "http://danmccreary.com/config" at "../modules/config.xqm";

import module namespace s = "http://danmccreary.com/spark" at "../modules/spark.xqm";

let $config := $config:config

let $param := 'led'
let $value := 'l1,HIGH'

return
<test-case>
  <input>
     {$config}
     <param>{$param}</param>
     <value>{$value}</value>
  </input>
  <output>
    {s:send('foo', 'bar', $config)}
  </output>
</test-case>