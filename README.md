# README #

This application is an eXist front end for testing the Spark.io REST libraries.  The Spark Core, is an Arduino-compatible, Wi-Fi dev platform that makes creating internet-connected hardware a breeze.

### Depends On ###
To run this app you will need eXist 2.2.
To build from source you will need Apache Ant and Java installed.

### Build ###

Add the following to your spark/git/info/exclude:

   build/local.properties
   build/packages/spark.xar

Setup the build/local.properties from the templates:


```
#!java
exist-home=D:\\exist\\exist2.2
app-id=spark
git-master=D:\\ws\\${app-id}
app-checkout=${git-master}/app
local-host=localhost:8080/exist
local-uri=xmldb:exist://${local-host}/xmlrpc/db
app-collection-uri=${local-uri}/apps/${app-id}
local-user=admin
local-password=
local-backup-dir=/tmp
```

cd into build and run
ant -p

If you don't have ant you can upload the app directory into /db/apps/spark on eXist-db.