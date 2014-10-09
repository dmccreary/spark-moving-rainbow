xquery version "3.0";

module namespace config = "http://danmccreary.com/config";
(:
import module namespace config = "http://danmccreary.com/config" at "../modules/config.xqm";
:)

(: if you type in "$config:" you should be a prompt for any of the following variables 
Avoid the xmldb:exist:///db paths for users :)

declare variable $config:server-name := request:get-server-name(); (: eg. 'localhost' :)
declare variable $config:hostname := request:get-hostname(); (: the IP address :)
declare variable $config:context := request:get-context-path(); (: 'exist' or '/' :)
declare variable $config:port-number := request:get-server-port(); (: integer :)
declare variable $config:exist-host := 
  if ($config:port-number = 80)
    then concat('http://', $config:server-name)
    else concat('http://', $config:server-name, ':', $config:port-number);

declare variable $config:web-base := concat($config:exist-host, $config:context);

declare variable $config:app-id := 'spark';
declare variable $config:app-home-collection := concat('/db/apps/', $config:app-id);
declare variable $config:config-file-path := concat($config:app-home-collection, '/config.xml');
declare variable $config:config := doc($config:config-file-path)/config;

declare variable $config:app-version := $config:config/app-version/text();

(: all the pending updates will go into this file :)
declare variable $config:pending-update-file-name := 'pending-updates.xml';

(: look for a device id - if not return an error :)
declare variable $config:device-id :=
   if ($config:config/device-id)
     then $config:config/device-id/text()
     else 'Error - no device-id found in config.xml';

(: look for a device id - if not return an error :)
declare variable $config:access-token :=
   if ($config:config/access-token)
     then $config:config/access-token/text()
     else 'Error - no access-token found in config.xml';