import module namespace s = "http://danmccreary.com/spark" at "../modules/spark.xqm";
import module namespace xqjson="http://xqilla.sourceforge.net/lib/xqjson";
import module namespace jpx = "http://danmccreary.com/jpx" at "../modules/jpx.xqm";

let $variable := request:get-parameter('variable', 'analogvalue')

let $json-string := s:value($variable)
let $xml-pairs := xqjson:parse-json($json-string)
let $xml-element-names := jpx:json-pairs-to-element($xml-pairs)
return
<test-case>
  {$xml-element-names}
</test-case>