<?php
//exec("ifconfig | grep 'inet 10.' | awk '{print $2}'", $results);
exec("ifconfig | egrep '\binet (addr:)?' | awk '!/127.0.0.1/{print $2}' | cut -d ':' -f 2", $results);
print_r($results);
?>
