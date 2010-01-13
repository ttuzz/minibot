<?php
	// проверяем ип и порт через запуск сокета. @ - означает отключение вывода ошибок
	define("auth", "#AUTH");
	define("valid", "#VALID");
	define("invalid", "#INVALID");
	define("request", "#REQUEST");
	define("send", "#SEND");
	
	$ip = '188.16.120.154';
	$port = 5000;
	$sock = fsockopen($ip, $port, $errno, $errstr, 5);
	if (!$sock)
	{
		echo "!sock!!!";
		return false;
	};
	
	fputs($sock, request.':'.session_id()."\r\n");
		
	// забираю ответ
	// TODO: сделать небольшую задержку для медленного коннекта
	$line = fgets ($sock);

	// закрываю сокет
	fclose($sock);
	
	echo $line;
?>