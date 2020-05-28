xquery version "1.0-ml";

module namespace plugin = "http://marklogic.com/data-hub/plugins";

import module namespace consts = "http://abnamro.nl/data-hub/consts" at "/ext/data-hub/consts/config.xqy";
import module namespace headers = "http://abnamro.nl/data-hub/headers" at "/ext/data-hub/lib/headers-lib.xqy";
import module namespace mapping = "http://abnamro.nl/data-hub/mapping" at "/ext/data-hub/lib/mapping-sdm.xqy";

declare option xdmp:mapping "false";

(:~
 : Create Headers Plugin
 :
 : @param $id      - the identifier returned by the collector
 : @param $content - the output of your content plugin
 : @param $options - a map containing options. Options are sent from Java
 :
 : @return - zero or more header nodes
 :)
declare function plugin:create-headers(
  $id as xs:string,
  $content as item()?,
  $options as map:map) as node()*
{
  let $checksum := map:get($options, "checksum")
  return
    if (fn:exists($content)) then (
      headers:generate-aol-headers(map:get($options, "job-id"),
        map:get($options, "source"),
        if ($checksum) then $checksum else xdmp:md5(xdmp:quote($content))
      ),
      let $hmap := mapping:extract-input-headers($content/fn:local-name(.), map:get($options, "entity"), map:get($options, "flow"), $content)
      return (
        headers:generate-sdm-headers(map:get($hmap, "headers")),
        if (map:keys(map:get($hmap, "errors"))) then
          xdmp:with-namespaces(("ns", $consts:NAMESPACE),
            element ns:errors {
              headers:generate-sdm-errors(map:get($hmap, "errors"))
            }
          )
        else ()
      )
    ) else ()
};
