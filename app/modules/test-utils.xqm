xquery version "3.0";

(: Tools for testing XQuery function :)
module namespace test-utils = "http://danmccreary.com/test-utils";
(:
import module namespace test-utils = "http://danmccreary.com/test-utils" at "../modules/test-utils.xqm";
:)

import module namespace util2 = "http://danmccreary.com/util2" at "util2.xqm";

declare variable $test-utils:version := 1;

declare variable $test-utils:app-home-collection := '/db/apps/spark';
declare variable $test-utils:app-unit-test-collection := concat($test-utils:app-home-collection, '/unit-tests');
declare variable $test-utils:app-unit-test-auto-collection := concat($test-utils:app-home-collection, '/unit-tests-auto');

declare variable $test-utils:resources-collection := concat($test-utils:app-home-collection, '/resources');
declare variable $test-utils:images-collection := concat($test-utils:resources-collection, '/images');
declare variable $test-utils:css-collection := concat($test-utils:resources-collection, '/css');

(: report on test status for a given collection 
@param $collection is the base collection to look for unit tests to list
   For example use '/db/apps/questiondb/unit-tests'
:)
declare function test-utils:test-status($collection as xs:string) as node() {

let $test-status-path := concat($collection, '/test-status.xml')
let $tests := doc($test-status-path)//test

(: don't show the index or non-xquery or html files :)
let $filtered-files :=
   for $file in xmldb:get-child-resources( $collection )
   return
     if (
          not($file='index.xq')
         )
             then $file
             else ()
             
(: the default order is by last update :)
let $sort := request:get-parameter('sort', 'last-modified')

let $sorted-files :=
   if ($sort = 'last-modified')
   then
        for $file in $filtered-files
        order by xs:dateTime(xmldb:last-modified($collection, $file)) descending
        return
           $file
     else if ($sort = 'pass-fail')
        then
        for $file in $filtered-files
        let $test := $tests[file=$file]
        order by $test/status/text()
        return
           $file
           (: the fall through default is by file name :)
     else
       for $file in $filtered-files
        order by $file
        return
           $file
   
return
<div class="content">
      sort: 
      {if ($sort = 'last-modified') then 'Last Modified'
      else if ($sort = 'pass-fail') then 'Pass Fail'
      else 'File Name'
     }
      <table class="table table-striped">
         <thead>
            <tr>
               <th class="span-5">File <a href="{request:get-uri()}?sort=name">sort by file name</a> </th>
               <th class="span-10">Description</th>
               <th class="span-1">Status <a href="{request:get-uri()}?sort=pass-fail">Sort</a></th>
               <th class="span-2">Modified <a href="{request:get-uri()}?sort=last-modified">Sort</a></th>       
            </tr>
         </thead>
      {for $file at $count in $sorted-files
         let $test := $tests[file=$file]
         return
             <tr>
                {if ($count mod 2)
                    then attribute class {'odd'}
                    else attribute class {'even'}
                 }
                <td style="text-align:left;"><a href="{$file}">{$file}</a></td>
                <td style="text-align:left;">{$test/desc/text()}</td>
                <td style="text-align:center;">
                 {if ($test/status/text() = 'fail') 
                    then <span class="fail">fail</span>
                    else <span class="pass">pass</span>
                 }
                </td>
                <td style="text-align:left;">{util2:us-dateTime(xmldb:last-modified($collection, $file))}</td>
             </tr>
      }
      </table>
   Test Status at <a href="/rest{$test-status-path}">{$test-status-path}</a>
</div>
};


declare function test-utils:child-to-links($base-collection as xs:string) as node() {
<span class="links">{
  for $child in xmldb:get-child-collections($base-collection)
        order by $child
        return
           (<a href="{request:get-uri()}?cat={$child}">{
             if ($child = 'css')
                then 'CSS'
                else if ($child = 'images') then ()
                else
             concat(
                  upper-case(substring($child, 1, 1)),
                  substring($child, 2)
                )
             }
           </a>, ' '
          )    
}</span>
};

(: by default, with no params, we show the non-automated test results :)
declare function test-utils:test-status() as node() {
let $collection := $test-utils:app-unit-test-collection
return
  test-utils:test-status($collection)
};

(: takes any node and returns the test id of that node.
The test ID is defined as {directory}/{filename}
Where directory is the name of the directory in the test folder and file name is the full file name with extension.
:)
declare function test-utils:test-id($node as node()) as xs:string {
    let $full-collection-name := util:collection-name($node)
    (: get the collection after the last slash :)
    let $last-dir := tokenize($full-collection-name, '/')[last()]
    let $file-name := util:document-name($node)
    return concat($last-dir, '/', $file-name)
};

(: Given a directory and a match-pattern this will return an XML file with all the categories and file names
   For the primary and child directories.
    <test-files>
       <file cat="css" file-name="css-form-wireframe.xml"/>
    </test-files>
:)
declare function test-utils:list-test-files-in-dir($base-dir as xs:string, $extensions as xs:string) as node() {
let $level-1-files :=
   for $file in xmldb:get-child-resources($base-dir)
     return
        <file cat="" file-name="{$file}"/>
let $level-2-files :=
  for $child-collection in xmldb:get-child-collections($base-dir)
        for $file in xmldb:get-child-resources(concat($base-dir, '/', $child-collection))
        return
           <file cat="{$child-collection}" file-name="{$file}"/>
return
<test-files>
   {for $file-element in ($level-1-files, $level-2-files)
      let $file-name := $file-element/@file-name
      order by $file-element/@cat, $file-name
      return
      if (test-utils:match-extension($file-name, $extensions) and 
          (
           ($file-name ne 'test-status.xml') and
           ($file-name ne 'index.xq')
           )
          )
         then $file-element
         else ()
    }
</test-files>
};

(: list only the files that end in xunit.xq :)
declare function test-utils:list-xunit-files($base-dir as xs:string) as node() {
let $level-1-files :=
   for $file in xmldb:get-child-resources($base-dir)
     return
        <file cat="" file-name="{$file}"/>
let $level-2-files :=
  for $child-collection in xmldb:get-child-collections($base-dir)
        for $file in xmldb:get-child-resources(concat($base-dir, '/', $child-collection))
        return
           <file cat="{$child-collection}" file-name="{$file}"/>
return
<test-files>
   {for $file-element in ($level-1-files, $level-2-files)
      let $file-name := $file-element/@file-name
      order by $file-element/@cat, $file-name
      return
      if (ends-with($file-name, 'xunit.xq'))
         then $file-element
         else ()
    }
</test-files>
};

(: Tf the file path is bla-bla-bla/css/foobar.xml and the list of extensions is a single
space delimited string "xml html xhtml" then
This will return true if the file path matches any of the extensions :)
declare function test-utils:match-extension($file-path as xs:string, $extensions as xs:string) as xs:boolean {
(: note we are ony using space delimted strings :)
let $valid-extensions := tokenize($extensions, '\s')[string-length(.) ge 1]
return
some $extension in $valid-extensions
   satisfies (ends-with($file-path, concat('.', $extension)))
};

(: does an eval on the URI :)
declare function test-utils:run-xunit($uri as xs:string) as node()? {
let $eval := 
   try {util:eval(xs:anyURI($uri))}
   catch * {<error>Can not run eval on {$uri}</error>}
return $eval
};

(: run an entire test suite.  If no category then run ALL tests :)
declare function test-utils:run-testsuite($cat as xs:string, $debug as xs:boolean) as node()? {
let $auto-test-collection :=
  if ($cat = '')
     then $test-utils:app-unit-test-auto-collection
     else concat($test-utils:app-unit-test-auto-collection, '/', $cat)

(: list all files that end it xunit.xq 
<test-files>
    <file cat="" file-name="01-template-xunit.xq"/>
    <file cat="abc" file-name="mytest-xunit.xq"/>
</test-files>
:)
let $tests := test-utils:list-xunit-files($auto-test-collection)

return
<testsuite>{
for $test at $count in $tests/file
   let $conditional-cat :=
      if (string-length($test/@cat) gt 0)
         then concat($test/@cat, '/')
         else ''
   let $url := concat($auto-test-collection, '/', $conditional-cat, $test/@file-name)
   let $eval :=
      try {util:eval(xs:anyURI($url))}
      catch * {<testcase><error/></testcase>}
   return
       <testcase count="{$count}" cat="{$test/@cat}" file="{$test/@file-name}">{$eval/@*} {$eval/*}</testcase> 
}</testsuite>
};

(: input format is:
  <testsuite>
    <testcase category="my-category" file-name="my-test-xunit.xq" name="mytestname" classname="http://logicprep.com/modulename" time="0"/>
  </testsuite>
:)
declare function test-utils:test-results-to-html($test-results as node(), $base-cat as xs:string) as node() {
<table class="table table-striped table-bordered table-hover">
   <thead>
      <tr>
         <th class="span1">Test Number</th>
         <th>Test Name</th>
         <th>Module (classname)</th>
         <th class="span1">Test Status</th>
         <th>Time</th>
         <th>Run</th>
      </tr>
   </thead>
   <tbody>{
      for $testcase at $count in $test-results//testcase
        let $name := $testcase/@name/string()
        let $pass-fail-class :=
           if ($testcase/failure)
              then 'warning'
              else if ($testcase/error)
                 then 'error'
              else 'success'
        let $pass-fail-text :=
           if ($testcase/failure)
              then 'fail'
              else if ($testcase/error)
                 then 'error'
                 else 'pass'
         let $conditional-cat :=
            if (string-length($testcase/@cat) gt 0 or string-length($base-cat) gt 0)
               (: one or the other category will be present here :)
               then concat($testcase/@cat, $base-cat, '/')
               else ''
        return
           <tr class="{$pass-fail-class}">
              <th>{$count}</th>
              {if ($pass-fail-text ne 'error')
                 then
                 (
                     <td>{$name}</td>,
                     <td>{$testcase/@classname/string()}</td>,
                     <td>{$pass-fail-text}</td>,
                     <td>{$testcase/@time/string()}</td>
                  )
                  else
                     (<td colspan="2">{$conditional-cat}{$testcase/@file/string()}</td>,
                     <td>ERROR</td>,
                     <td></td>
                     )
              }
              <td>
                <a href="{$conditional-cat}{$testcase/@file/string()}">run</a>
              </td>
           </tr>
      }
   </tbody>
</table>
};

declare function test-utils:last-mod($node as node()) as xs:string {
   let $collection := util:collection-name($node)
   let $file-name := util:document-name($node)
   let $last-modified := xmldb:last-modified($collection, $file-name)
   return util2:us-dateTime($last-modified)
};