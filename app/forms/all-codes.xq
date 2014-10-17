xquery version "1.0";
import module namespace config = "http://danmccreary.com/config" at "../modules/config.xqm";

let $file-path1 := concat($config:code-table-collection, '/led-strip-pattern-code.xml')

return
<code-tables>
   {doc($file-path1)/code-table}
</code-tables>