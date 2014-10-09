xquery version "1.0";
(: a module for converting JSON pair format to element name format 
   Note: this may not work if the JSON names are not NCNames :)
module namespace jpx = "http://danmccreary.com/jpx";
(:
import module namespace jpx = "http://danmccreary.com/jpx" at "../modules/jpx.xqm";
:)
(: JSON Pair to XML element name converter :)

declare function jpx:json-pairs-to-element($node as node()*) as item()* {
    typeswitch($node)
        case text() return normalize-space($node)
        case element(pair) return
           jpx:pair($node)
        case element(item) return
           <item>{jpx:recurse($node)}</item>
        case element(json) return
           <json>{jpx:recurse($node)}</json>
        case comment() return $node
        default
          return <default>{$node}</default>
};

declare function jpx:recurse($nodes as node()*) as item()* {
    for $node in $nodes/node()
      return
        jpx:json-pairs-to-element($node)
};

declare function jpx:pair($pair as element()) as item()* {
if ($pair/@type eq 'string' or $pair/@type eq 'number' or $pair/@type eq 'boolean' or $pair/@type eq 'null')
  then 
     element {$pair/@name/string()} {normalize-space($pair/text())}
  
  else if ($pair/@type eq 'object' or $pair/@type eq 'array')
     then
       let $element-name :=
         if ($pair/@name/string())
            then $pair/@name/string()
            else 'object'
       return
       element {$element-name} {jpx:recurse($pair)}
     else <unknown-pair>{$pair}</unknown-pair>
};