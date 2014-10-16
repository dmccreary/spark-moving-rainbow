import module namespace config = "http://danmccreary.com/config" at "../modules/config.xqm";

import module namespace s = "http://danmccreary.com/spark" at "../modules/spark.xqm";

<test-case name="devices" classname="spark">
    {s:devices()}
</test-case>