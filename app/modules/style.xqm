xquery version "3.0";

module namespace style = "http://danmccreary.com/style";
(:
import module namespace style = "http://danmccreary.com/style" at "../modules/style.xqm";
:)

declare namespace request="http://exist-db.org/xquery/request";
declare namespace xf="http://www.w3.org/2002/xforms";
declare namespace xrx="http://code.google.com/p/xrx";
declare namespace repo="http://exist-db.org/xquery/repo";

declare variable $style:context := request:get-context-path(); (: / or /exist :)
declare variable $style:conditional-port :=
  if (request:get-server-port() = 80)
    then ()
    else concat(':', string(request:get-server-port()));
    
declare variable $style:url-base :=
  concat(
    'http://',
    request:get-server-name(),
    $style:conditional-port,
    $style:context
    );

declare variable $style:app-home := '/db/apps/spark';
declare variable $style:data-collection := concat($style:app-home, '/data');
declare variable $style:repo-file-path := concat($style:app-home, '/repo.xml');
declare variable $style:repo-doc := doc($style:repo-file-path)/repo:meta;

declare variable $style:web-path-to-site := $style:app-home;
declare variable $style:rest-path-to-site := concat($style:context, '/rest', $style:web-path-to-site);
declare variable $style:web-path-to-app := style:substring-before-last-slash(style:substring-before-last-slash(substring-after(request:get-uri(), '/rest')));
declare variable $style:rest-path-to-app := concat($style:context, '/rest', $style:web-path-to-app);

declare variable $style:db-path-to-site  := concat('xmldb:exist://',  $style:web-path-to-site);
declare variable $style:db-path-to-app  := concat('xmldb:exist://', $style:web-path-to-app) ;
declare variable $style:db-path-to-app-data := concat($style:app-home, '/data');

declare variable $style:app-id := $style:repo-doc//repo:target/text();
declare variable $style:app-name := 'Spark.io REST API Test Application';

declare variable $style:site-resources := concat($style:app-home, '/resources');
declare variable $style:rest-path-to-style-resources := concat($style:context, '/rest', $style:site-resources);
declare variable $style:site-images := concat($style:site-resources, '/images');
declare variable $style:site-scripts := concat($style:site-resources, '/js');
declare variable $style:rest-path-to-images := concat($style:context, '/rest', $style:site-images);

declare variable $style:config-file-path := concat($style:app-home, '/config.xml');
declare variable $style:config := doc($style:config-file-path)/config;
declare variable $style:header-dark-gray := '#455560';

 (: home = 1, apps = 2 :)
 declare function style:web-depth-in-site() as xs:integer {
(: if the context adds '/exist' then the offset is six levels.  If the context is '/' then we only need to subtract 5 :)
let $offset := 
   if ($style:context)
then 4 else 3
    return count(tokenize(request:get-uri(), '/')) - $offset
};

(: 

<span id="banner-search">
                <form id="banner-form-search" class="form-search" method="GET" action="{$style:rest-path-to-app}/db/apps/grants/search/search.xq">
                    <input name="q" type="text" size="10"/>
                    <input type="submit" value="Search"/>
                </form>
            </span>
            
            <span id="banner-login"> 
                {let $current-user := xmldb:get-current-user()
                 return
                   if ($current-user eq 'guest')
                      then ()
                      else
                         <a href="{$style:web-path-to-app}/admin/user-prefs.xq">{concat("Logged in as user: ", $current-user)}</a>
                }
            </span>

:)
declare function style:header()  as node()*  {
    <div id="header">
        
       
        <div id="banner">
            <span id="logo">
               <a href="{$style:rest-path-to-site}/index.xq">
                   <img src="{$style:rest-path-to-images}/mhs-logo-145-white.png" alt="Minnesota Historical Society"/>
               </a>
             </span>   
        </div>
        <div class="banner-seperator-bar"/>
    </div>   
};

declare function style:footer()  as node()*  {
<div id="footer">
   <div class="banner-seperator-bar"/>
   <hr/>
   <div id="footer-text" style="text-align: center;">Copyright 2014 {$style:app-name}. All rights reserved.
      <a href="mailto:dan@danmccreary.com">Feedback</a>
   </div>
</div>
};

(:       &gt; <a href="{$style:rest-path-to-site}/apps/index.xq">Apps</a>
      
      {if (style:web-depth-in-site() > 2) then
      (' &gt; ',
      <a href="{$style:rest-path-to-site}/apps/{$style:app-id}/index.xq">Test Cases</a>
      )
      else ()}
      
      {if ($suffix) then (' &gt; ', $suffix) else ()}
      &gt; 
      <a href="{$style:rest-path-to-site}/views/list-items.xq">List Items</a>
      :)
declare function style:breadcrumbs($suffix as node()*) as node() {
   <div class="breadcrumbs">
      <a href="{$style:rest-path-to-site}/index.xq">Home</a> 
   </div>
};

declare function style:css($page-type as xs:string) 
as node()+ {
    if ($page-type eq 'xhtml') then 
        (
            <link rel="stylesheet" href="{$style:rest-path-to-style-resources}/css/bootstrap.min.css" type="text/css" media="screen, projection"/>,
            <link rel="stylesheet" href="{$style:rest-path-to-style-resources}/css/site.css" type="text/css" media="screen, projection" />
        )
    else if ($page-type eq 'xforms') then
        (
            <link rel="stylesheet" href="{$style:rest-path-to-style-resources}/css/xforms-css.xq" type="text/css" />
        )
    else ()
};

declare function style:assemble-page($title as xs:string*, $breadcrumbs as node()*, 
                                     $style as element()*, $content as node()+) as element() {
    (
    util:declare-option('exist:serialize', 'method=xhtml media-type=text/html indent=yes')
    ,
    <html xmlns="http://www.w3.org/1999/xhtml">
        <head>
            <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
            <link rel="shortcut icon" href="{$style:rest-path-to-style-resources}/images/mnhs-logo-75px.png"/>
            <title>{$title}</title>
            {style:css('xhtml')}
            {if (string-length($style) gt 0)
               then $style else ()
            }
        </head>
        <body>
            <div class="container">
                {style:header()} 
                {style:breadcrumbs($breadcrumbs)}
                <h4>{$title}</h4>
                <div class="inner">
                    {$content}
                </div>
                {style:footer()}
            </div>
        </body>
     </html>
     )
};

(: Just pass title and content.  Put in the default breadcrumb and null for style :)
declare function style:assemble-page($title as xs:string, $content as node()+) as element() {
    style:assemble-page($title, (), (), $content)
};

declare function style:substring-before-last-slash($arg as xs:string?)  as xs:string {
       
   if (matches($arg, '/'))
   then replace($arg,
            concat('^(.*)', '/','.*'),
            '$1')
   else ''
 } ;
 
 
declare function style:assemble-form($title as xs:string, $form as node()) as item()* {
let $config := $style:config
let $serialize-options := util:declare-option('exist:serialize', 'method=xhtml media-type=text/xml indent=yes process-xsl-pi=no')
let $debug :=
   if ($config/debug = 'true')
   then processing-instruction xsltforms-options {'debug="yes"'}
   else processing-instruction xsltforms-options {'debug="no"'}
let $xslt-pi := processing-instruction xml-stylesheet {'type="text/xsl" href="/exist/rest/db/apps/xsltforms/xsltforms.xsl"'}
            return ($xslt-pi, $debug, $form)
};

(: unconditionally run in debug mode :)
declare function style:assemble-form-debug($title as xs:string, $form as node()) as item()* {
let $serialize-options := util:declare-option('exist:serialize', 'method=xhtml media-type=text/xml indent=yes process-xsl-pi=no')
let $debug := processing-instruction xsltforms-options {'debug="yes"'}
let $xslt-pi := processing-instruction xml-stylesheet {'type="text/xsl" href="/exist/rest/db/apps/xsltforms/xsltforms.xsl"'}
            return ($xslt-pi, $debug, $form)
};

(: remove the PI for XSLTForms :)
declare function style:assemble-form-orbeon($title as xs:string, $form as node()) as item()* {
let $serialize-options := util:declare-option('exist:serialize', 'method=xhtml media-type=text/xml indent=yes')
return $form
};

declare function style:assemble-form(
        $title as xs:string,
        $model as node(),
        $style as node()*,
        $content as node()+, 
        $debug as xs:boolean) as node()+ {
let $dummy := request:set-attribute("betterform.filter.ignoreResponseBody", "true")
let $xslt-pi := processing-instruction xml-stylesheet {'type="text/xsl" href="/exist/rest/db/apps/xsltforms/xsltforms.xsl"'}
let $debug-pi :=
      if ($debug)
        then processing-instruction xsltforms-options {'debug="yes"'}
        else ()
let $form :=
    <html  
      xmlns:xf="http://www.w3.org/2002/xforms" 
      xmlns:ev="http://www.w3.org/2001/xml-events"
      >
        <head>
            <title>{ $title }</title>
            <link rel="shortcut icon" href="{$style:rest-path-to-style-resources}/images/mnhs-logo-75px.png"/>
            <link rel="stylesheet" href="{$style:rest-path-to-style-resources}/css/bootstrap.min.css" type="text/css" media="screen, projection"/>
            {$model}
            {style:css('xforms')}
            {if (string-length($style) gt 0)
               then $style else ()
            }
        </head>
        <body>
            <div class="container">
                {style:header()} 
                {style:breadcrumbs(())}
                <h2>{$title}</h2>
                {$content}
                {style:footer()}
            </div>
        </body>
    </html>
return ($xslt-pi, $debug-pi, $form)
};

declare function style:assemble-form1($form as node(), $debug as xs:boolean) as node()* {
let $dummy := request:set-attribute("betterform.filter.ignoreResponseBody", "true")
let $xslt-pi := processing-instruction xml-stylesheet {'type="text/xsl" href="/exist/rest/db/apps/xsltforms/xsltforms.xsl"'}
let $debug-pi :=
   if ($debug)
      then processing-instruction xsltforms-options {'debug="yes"'}
      else processing-instruction xsltforms-options {'debug="no"'}
return ($xslt-pi, $debug-pi, $form)
};