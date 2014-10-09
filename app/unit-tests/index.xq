import module namespace style = "http://danmccreary.com/style" at "../modules/style.xqm";
import module namespace test-utils = "http://danmccreary.com/test-utils" at "../modules/test-utils.xqm";


let $title := 'List Unit Tests'

let $content :=
<div class="content">
     {test-utils:test-status()}
</div>

return style:assemble-page($title, $content)