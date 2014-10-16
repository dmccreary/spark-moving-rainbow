(: wraps all css in a <css> XML element, required by XSLTForms
 : TODO: look into how to set up a print stylesheet, since including 'blueprint/print.css' here 
 :       turns the entire page into the print-ready form on screen 
 : TODO: figure out how to pass util:binary-doc a relative URL, or somehow get the path via controller.xql
 :       so that we don't have to hardcode it here
 :)
import module namespace style = "http://danmccreary.com/style" at "../../modules/style.xqm";

declare option exist:serialize "method=xml media-type=text/css indent=yes";

let $path-to-css-files := concat($style:app-home, '/resources/css')
return
  if (not(xmldb:collection-available($path-to-css-files)))
     then
        <error>Collection {$path-to-css-files} is not available</error>
else

let $css-files :=  ('site.css', 'bootstrap.min.css')

return
<css>
/*  XML element wrapper for XSLTForms CSS processing */

{
  for $css-file in $css-files 
    
        return util:binary-to-string(util:binary-doc(concat($path-to-css-files, '/', $css-file)))
        }
</css>
