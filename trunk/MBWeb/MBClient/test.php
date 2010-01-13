<?php
if ($_POST['pass'] == "<tetra_om>")
{
	$url = 'http://www.yandex.ru'; 
	print_r($purl = parse_url($url)); 
	$fp = fsockopen($purl['host'],80); 
	if ($fp){ 
	  fwrite($fp,"GET $url HTTP/1.0\nHost: {$purl['host']}\n\n"); 
	  while(!feof($fp)) echo fgets($fp); 
	  fclose($fp); 
	}
};
?>