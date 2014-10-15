xquery version "1.0";
import module namespace style = "http://danmccreary.com/style" at "modules/style.xqm";
import module namespace config = "http://danmccreary.com/config" at "modules/config.xqm";

let $title := 'Spark.io REST API Test Application'


let $content :=
<div class="content">
     <p>This application tests the spark.io REST API.</p>
     
     
     Application Version: <b>{$config:app-version}</b> Last updated: {$config:last-updated-date}<br/>
     
     <a href="unit-tests/index.xq">Unit Tests</a><br/>
     
     
     <h4>External Links</h4>
     
     <a href="https://www.spark.io/build" target="_blank">Spark Web IDE</a><br/>
     <a href="https://github.com/lumiere-lighting" target="_blank">Link to Lumière site on github</a><br/>
     <a href="http://iothackday.mn/team-descriptions" target="_blank">Internet of Things Hackday team</a><br/>
     <a href="http://docs.spark.io/api/" target="_blank">Spark REST API Docs</a><br/>
     <a href="http://docs.spark.io/firmware" target="_blank">Spark Firmware Calls</a><br/>
     <br/>
     
     <p>Please contact <a href="mailto:dan.mccreary@gmail.com">Dan McCreary</a> if you have any feedback on this app.</p>
</div>

return style:assemble-page($title, $content)