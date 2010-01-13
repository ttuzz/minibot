<?php
	/* содержит функцию проверки ip, порта
	 * а также авторизации на сервере
	 * !!!Открывает сокет!!!
	 */
	 
	// формат строки авторизации
	//	клиент: "#AUTH:session_id():pass"
	//	сервер: "#VALID" or "#INVALID"
	
	// формат строки запроса данных
	//	клиент: "#REQUEST:session_id()"
	//	сервер: "#VALID:данные" or "#INVALID"
	
	// формат строки отправки данных
	//	клиент: "#SEND:session_id():данные"
	//	сервер: "#VALID" or "#INVALID"
	
	define("auth", "#AUTH");
	define("request", "#REQUEST");
	define("send", "#SEND");
	define("valid", "#VALID");
	define("invalid", "#INVALID");
	
	function user_validate($ip, $port, $pass, &$errno, &$errstr, $timeout=5)
	{		
		// проверяем ип и порт через запуск сокета. @ - означает отключение вывода ошибок
		$sock = @fsockopen($ip, $port, $errno, $errstr, $timeout);
		if (!$sock)
		{
			fclose($sock);
			echo "!sock!!!";
			return false;
		};
		
		// готовлю данные для регистрации на сервере
		fputs($sock, auth.':'.session_id().':'.$pass."\r\n");
		
		// проверяю ответ
		// TODO: сделать небольшую задержку для медленного коннекта
		$line = fgets ($sock);

		// закрываю сокет
		fclose($sock);
		
		$line = trim($line);		
		if ($line == valid) 
		{
			return true;
		}else
		{
			return false;
		};	
	};
	
	function get_str($ip, $port, &$errno, &$errstr, $timeout=5)
	{		
		// запуск сокета. @ - означает отключение вывода ошибок
		$sock = @fsockopen ($ip, $port, $errno, $errstr, $timeout);
		if (!$sock)
		{
			echo $errsr;
			return false;
		};
		
		// готовлю запрос данных
		fputs($sock, request.':'.session_id()."\r\n");
		
		// забираю ответ
		// TODO: сделать небольшую задержку для медленного коннекта
		$line = fgets ($sock);
		// TODO: удалить лишнюю инфу(про валидность/невалидность) из строки
		
		// закрываю сокет
		fclose($sock);
		
		return $line;
	};
	
	function send_str($string, $ip, $port, &$errno, &$errstr, $timeout=5)
	{		
		// запуск сокета. @ - означает отключение вывода ошибок
		$sock = @fsockopen ($ip, $port, $errno, $errstr, $timeout);
		if (!$sock)
		{
			fclose($sock);
			return false;
		};
		
		// готовлю запрос данных на сервере
		fputs($sock, send.':'.session_id().':'.$string."\r\n");
		
		// проверяю ответ
		// TODO: сделать небольшую задержку для медленного коннекта
		$line = fgets ($sock);
		
		// закрываю сокет
		fclose($sock);
		
		$line = trim($line);
		if ($line == valid) 
		{
			return true;
		}else
		{
			return false;
		};	
	};
?>