<?php
	require "socks.php";	//контейнер процедур работы с сервером	
	
	define("max_count_lines", 25);	// максимальное количество строк в выводе
		
	session_start();	// запускаю сессию
	$line = get_str($_SESSION['ip'], $_SESSION['port'], $errno, $errstr);
	if (($line == false)||!isset($_SESSION['lines']))
	{
		Header("Location: auth.php"); 
		exit(); 
	};
	
	if (count($_SESSION['lines']) > max_count_lines) { array_shift($_SESSION['lines']); };
	array_push($_SESSION['lines'], $line);
?>

<html>
<head>
	<title>“ерминал</title>
	<script language="javascript" type="text/javascript">
		function timer()
		{
			setTimeout('refresh();', 5000);	// через 5 сек вызывать refresh();
		}
		function refresh()
		{
			//window.location.href = 'test.html';
			window.location.reload();	// обновл€ю страницу
			//window.open("http://rambler.ru/");			
		}
	</script>
</head>
<body onload="javascript:timer()" onunload="javascript:window.location = 'onclose.php'">
	<?php
		// вывожу ошибку если есть
	?>
	ѕрин€тые данные</br>
	<textarea name="input" cols="75" rows="30" 
	><?php
		echo implode("",$_SESSION['lines']);
	?></textarea></br>
</body>
</html>

<?php
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