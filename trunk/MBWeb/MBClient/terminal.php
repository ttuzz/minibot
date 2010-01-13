<?php
	session_start();
?>

<html>
<head>
	<title>Терминал</title>
</head>
<body>
<?php
	
    $ip = 'localhost';
    $port    = 5003;
	if ($ip!="") 
	{ 
	  $sock = fsockopen ($ip, $port, $errno, $errstr, 5); 
	  if (!$sock) 
	  { 
		echo("$errno($errstr)"); 
		return; 
	  } 
	  else 
	  { 
		fputs ($sock, "connected\r\n"); 
		$line = fgets ($sock);
		/*
		while (!feof($sock)) 
		{ 
		  echo (str_replace(":",":&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;", 
								  fgets ($sock,128))."<br>"); 
		} 
		*/
	  } 
	  fclose ($sock); 
	} 
?>


	<form action="terminal.php" method="POST" name="terminal">
		Принятые данные</br>
		<textarea name="input" cols="75" rows="30" 
		><?php
			echo $line
		?></textarea></br>
		Отправить</br>
		<input type="text" name="output" size="100">
	</form>
</body>
</html>

