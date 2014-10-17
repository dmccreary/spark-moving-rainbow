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

(:
<xf:instance id="code-tables" xmlns="" src="all-codes.xq"/>
<xf:itemset ref="instance('code-tables')/code-table/items/item">
           <xf:label ref="./label"/>
           <xf:label ref="./value"/>
</xf:itemset>
:)

let $style := 
<style>
body{{font-family: helvetica, ariel, sans-serif;}}
.xforms-control {{display:block;}}
.xforms-label {{display:inline-block; width: 15ex; font-weight: bold; text-align: left; font-size: 10pt; margin-right: 1ex;}}
.xforms-item {{margin-left: 5ex;}}
</style>

let $model :=
<xf:model>
   <xf:instance id="spark-state" xmlns="">
      <data>
            <new-state></new-state>
            <pattern>rainbow</pattern>
      </data>
   </xf:instance>
   
   
   
   <xf:instance id="spark-result" xmlns="">
      <null/>   
   </xf:instance>
   
   <xf:submission id="change-pattern" method="get" 
      replace="instance" instance="spark-result"
      serialization="none" mode="synchronous" mediatype="text/xml">
      <xf:resource value="concat('../scripts/new-pattern.xq?new-pattern=', instance('spark-state')/pattern)"/>
   </xf:submission>
   
   <xf:submission id="led-change" method="get" 
      replace="instance" instance="spark-result"
      serialization="none" mode="synchronous" mediatype="text/xml">
      <xf:resource value="concat('../scripts/led-state-change.xq?new-state=', instance('spark-state')/new-state)"/>
   </xf:submission>
   
</xf:model>

let $content :=
<div class="content">
      <h4>{$title}</h4>
      
      <xf:output ref="pattern">
         <xf:label>Current Pattern:</xf:label>
      </xf:output>
      
      <xf:select1 ref="pattern" appearance="full">
         <xf:label>Change Pattern:</xf:label>
            <xf:item>
               <xf:label>Rainbow</xf:label>
               <xf:value>rainbow</xf:value>
            </xf:item>
            <xf:item>
               <xf:label>Red</xf:label>
               <xf:value>red</xf:value>
            </xf:item>
            <xf:item>
               <xf:label>Orange</xf:label>
               <xf:value>orange</xf:value>
            </xf:item>
            <xf:item>
               <xf:label>Yellow</xf:label>
               <xf:value>yellow</xf:value>
            </xf:item>
            <xf:item>
               <xf:label>Green</xf:label>
               <xf:value>green</xf:value>
            </xf:item>
            <xf:item>
               <xf:label>Blue</xf:label>
               <xf:value>blue</xf:value>
            </xf:item>
            <xf:item>
               <xf:label>Indigo</xf:label>
               <xf:value>indigo</xf:value>
            </xf:item>
            <xf:item>
               <xf:label>Violet</xf:label>
               <xf:value>violet</xf:value>
            </xf:item>
            <xf:item>
               <xf:label>White</xf:label>
               <xf:value>white</xf:value>
            </xf:item>
            <xf:item>
               <xf:label>Dim</xf:label>
               <xf:value>dim</xf:value>
            </xf:item>
            <xf:item>
               <xf:label>Cyan</xf:label>
               <xf:value>cyan</xf:value>
            </xf:item>
            <xf:item>
               <xf:label>Race</xf:label>
               <xf:value>race</xf:value>
            </xf:item>
            <xf:item>
               <xf:label>Color Wipe</xf:label>
               <xf:value>colorwipe</xf:value>
            </xf:item>
            <xf:item>
               <xf:label>Color 100</xf:label>
               <xf:value>color100</xf:value>
            </xf:item>
            <xf:item>
               <xf:label>Color All 200</xf:label>
               <xf:value>colorall200</xf:value>
            </xf:item>
            <xf:item>
               <xf:label>Random Color</xf:label>
               <xf:value>random-color</xf:value>
            </xf:item>
            <xf:item>
               <xf:label>Random RGB</xf:label>
               <xf:value>random-rgb</xf:value>
            </xf:item>
            <xf:item>
               <xf:label>Candle Flicker</xf:label>
               <xf:value>candle</xf:value>
            </xf:item>
            <xf:item>
               <xf:label>Cylon</xf:label>
               <xf:value>cylon</xf:value>
            </xf:item>
            <xf:item>
               <xf:label>Up Down</xf:label>
               <xf:value>up-down</xf:value>
            </xf:item>
            <!-- fire off a new submisison any time this value changes -->
            <xf:send submission="change-pattern" ev:event="xforms-value-changed"/>
      </xf:select1>
      
      
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
      
      <xf:submit submission="change-pattern">
         <xf:label>Submit</xf:label>
      </xf:submit>
      
      <xf:submit submission="led-change">
         <xf:label>LED State</xf:label>
      </xf:submit>
      
      <xf:output ref="instance('spark-result')/spark-response-code">
         <xf:label>Spark Response Code</xf:label>
      </xf:output>
      
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
