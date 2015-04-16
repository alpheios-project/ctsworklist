import module namespace request="http://exist-db.org/xquery/request";
import module namespace transform="http://exist-db.org/xquery/transform";  
import module namespace cts="http://alpheios.net/namespaces/cts" 
            at "cts.xquery";
declare option exist:serialize "method=html media-type=text/html";


let $inv := request:get-parameter("inv","")
let $xml := cts:getCapabilities($inv)

return
  transform:transform($xml, doc("/db/xslt/inventory_to_list.xsl"), ())
