<?php
	require "socks.php";	//контейнер процедур работы с сервером
	
	session_start();
	if (!isset($_SESSION['sock'])||!$_SESSION['sock'])
	{
		// зашли не c нужной страницы без сокета
		$_SESSION['sock'] = 0;
		//Header("Location: index.html");
	}
?>

<html>
<head>
	<title>Терминал</title>
</head>
<body>
	<form action="output.php" method="POST" name="output">
		<?php
			// вывожу ошибку есть есть
		?>
		Отправить</br>
		<input type="text" name="output" size="84">
		<input type="button" name="send" value="Отправить" size="15"></br>
	</form>
</body>
</html>


<?php
	$line = $_POST['output'];
	if ($sock && $line)
	{
		echo "ok";
	};

	/*
    $ip = 'localhost';
    $port    = 5000;
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
		while (!feof($sock)) 
		{ 
		  echo (str_replace(":",":&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;", 
								  fgets ($sock,128))."<br>"); 
		} 
		
	  } 
	  fclose ($sock); 
	} 
	*/
?>
