xquery version "1.0";

import module namespace style = "http://danmccreary.com/style" at "../modules/style.xqm";
import module namespace config = "http://danmccreary.com/config" at "../modules/config.xqm";

declare namespace xf="http://www.w3.org/2002/xforms";
declare namespace ev="http://www.w3.org/2001/xml-events";
let $title := 'Demo of call function using Spark.io'

(: all-codes.xq - get all the code tables for an XForms edit form :)
let $debug := xs:boolean(request:get-parameter('debug', 'false'))
let $view-source := xs:boolean(request:get-parameter('view-source', 'false'))
let $betterform := xs:boolean(request:get-parameter('betterform', 'false'))

let $better-form-enable :=
   if ($betterform)
     then ()
     else request:set-attribute("betterform.filter.ignoreResponseBody", "true")

let $style := 
<style>
body{{font-family: helvetica, ariel, sans-serif;}}
.container {{margin-left: 5ex;}}
.xforms-control {{display:block;}}
.xforms-label {{display:inline-block; font-weight: bold; font-size: 10pt; margin-right: 1ex;}}
a.horizontal-links {{padding: 5px;}}
.xforms-item {{margin-left: 5ex;}}
</style>

let $model :=
<xf:model>
   <xf:instance id="led-status" xmlns="">
      <data>
            <new-state></new-state>
      </data>
   </xf:instance>
   
   <xf:instance id="spark-result" xmlns="">
      <null/>   
   </xf:instance>
   
   <xf:submission id="led-change" method="get" 
      replace="instance" instance="spark-result"
      serialization="none" mode="synchronous" mediatype="text/xml">
      <xf:resource value="concat('../scripts/led-state-change.xq?new-state=', new-state)"/>
   </xf:submission>
   
   <!-- <xf:submission id="s1" method="get" replace="instance" instance="iresults" serialization="none" mode="synchronous" mediatype="text/jsonp">
                <xf:resource value="concat('http://en.wikipedia.org/w/api.php?action=opensearch&amp;format=json&amp;search=',search)"/>
   </xf:submission>-->
</xf:model>

let $content :=
<div class="content">
      
      <xf:select1 ref="new-state" appearance="full" incremental="true">
         <xf:label>Turn LEDs:</xf:label>
            <xf:item>
               <xf:label>On</xf:label>
               <xf:value>on</xf:value>
            </xf:item>
            <xf:item>
               <xf:label>Off</xf:label>
               <xf:value>off</xf:value>
            </xf:item>
            <!-- fire off a new submisison any time this value changes -->
            <xf:send submission="led-change" ev:event="xforms-value-changed"/>
      </xf:select1>
      
      <!-- <xf:submit submission="led-change">
         <xf:label>Submit</xf:label>
      </xf:submit>
      -->
      <xf:output ref="instance('spark-result')/response-time">
         <xf:label>Response Time (ms):</xf:label>
      </xf:output>
      
</div>

return
  if ($view-source)
     then
       <debug xmlns="http://www.w3.org/1999/xhtml" xmlns:xf="http://www.w3.org/2002/xforms">
          {($title, $style, $model, $content)}
       </debug>
     else
       style:assemble-form($title, $model, $style, $content, $debug)
