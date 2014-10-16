import module namespace config = "http://danmccreary.com/config" at "../modules/config.xqm";
import module namespace xqjson="http://xqilla.sourceforge.net/lib/xqjson";
import module namespace jpx = "http://danmccreary.com/jpx" at "../modules/jpx.xqm";
import module namespace s = "http://danmccreary.com/spark" at "../modules/spark.xqm";

let $format := request:get-parameter('format', 'xml')

let $json-string := s:get-device-info()

return
  if ($format = 'json')
     then
         let $option := util:declare-option('exist:serialize', 'media-type=application/json')
         return $json-string
      else if ($format = 'xml-pairs')
         then xqjson:parse-json($json-string)
      else (: xml :)
        let $xml-pairs := xqjson:parse-json($json-string)
        return
          <device-status-full>
            <other-formats>json,xml-pairs</other-formats>
            {jpx:json-pairs-to-element($xml-pairs)/*}
          </device-status-full>