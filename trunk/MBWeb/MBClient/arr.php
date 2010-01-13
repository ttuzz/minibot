<?php
	/*
	$arr = array();
	$arr['car'] = '„айка';
	$arr['age'] = 100;
	$arr[10] = 'Ёлемент с ключом 10';
	foreach ($arr as $key=>$value)
		echo $value
	
	session_start();
	echo "First session: ".session_id()."<br/>";
	echo "Second session: ".session_id()."<br/>";
	session_destroy();
	echo "After destroyed: ".session_id()."<br/>";
	*/
	
	session_start();
	
	
	define("auth", "#AUTH");
	define("valid", "#VALID");
	define("invalid", "#INVALID");
	define("request", "#REQUEST");
	define("send", "#SEND");
	
	
		// провер€ем ип и порт через запуск сокета. @ - означает отключение вывода ошибок
		$sock = @fsockopen ('188.16.120.154', 5002, $errno, $errstr, 5);
		if (!$sock)
		{
			echo "!sock<br/>";
			echo $errstr."<br/>";
			return false;
		}else{
		
		
		// готовлю данные дл€ регистрации на сервере
		$putline=auth.":".session_id().':'."pass";				
		fputs ($sock, $putline.""); 
		echo "auth: ".$putline."<br/>";	
		$line = fgets ($sock);
		echo "line: ".$line."<br/>";
		
		/*
		fputs ($sock, "connected\r\n"); 
		$line = fgets ($sock);
		*/
		// провер€ю ответ
		// TODO: сделать небольшую задержку дл€ медленного коннекта
		/*
		$line = fgets ($sock);
		echo "line: ".$line."<br/>";
		
		// закрываю сокет
		fclose($sock);
		echo "socket closed</br>";
		*/
		/*
		if ($line == valid) 
		{
			echo "true";
			return true;
		}else
		{
			echo "false";
			return false;
		};	
		
		};
	fclose ($sock);
	echo "socket closed</br>";
	*/
?>