xquery version "1.0";

import module namespace style = "http://danmccreary.com/style" at "../modules/style.xqm";
import module namespace config = "http://danmccreary.com/config" at "../modules/config.xqm";

declare namespace xf="http://www.w3.org/2002/xforms";
declare namespace ev="http://www.w3.org/2001/xml-events";
let $title := 'Change LED Strip Pattern'

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
.xforms-control {{display:block;}}
.xforms-label {{display:inline-block; width: 15ex; font-weight: bold; text-align: left; font-size: 10pt; margin-right: 1ex;}}
.xforms-item {{margin-left: 5ex;}}
</style>

let $model :=
<xf:model>
   <xf:instance id="led-status" xmlns="">
      <data>
            <new-pattern></new-pattern>
      </data>
   </xf:instance>
   
   <xf:instance id="code-table" xmlns="" src="../code-tables/led-strip-pattern-code.xml"/>
   
   <xf:instance id="spark-result" xmlns="">
      <null/>   
   </xf:instance>
   
   <xf:submission id="change-pattern" method="get" 
      replace="instance" instance="spark-result"
      serialization="none" mode="synchronous" mediatype="text/xml">
      <xf:resource value="concat('../scripts/change-pattern.xq?new-pattern=', new-state)"/>
   </xf:submission>
   
</xf:model>

let $content :=
<div class="content">
      <h4>{$title}</h4>
      <xf:select1 ref="new-pattern" appearance="full" incremental="true">
         <xf:label>Change Pattern:</xf:label>
            <xf:itemset ref="instance('code-table')//item">
               <xf:label ref="label"/>
               <xf:label ref="value"/>
            </xf:itemset>
            <!-- fire off a new submisison any time this value changes -->
            <xf:send submission="change-pattern" ev:event="xforms-value-changed"/>
      </xf:select1>
      
      <!-- <xf:submit submission="led-change">
         <xf:label>Submit</xf:label>
      </xf:submit>
      -->
      <xf:output ref="instance('spark-result')/response-time">
         <xf:label>Response Time (ms)</xf:label>
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
