<?php
	/*
	$arr = array();
	$arr['car'] = '�����';
	$arr['age'] = 100;
	$arr[10] = '������� � ������ 10';
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
	
	
		// ��������� �� � ���� ����� ������ ������. @ - �������� ���������� ������ ������
		$sock = @fsockopen ('188.16.120.154', 5002, $errno, $errstr, 5);
		if (!$sock)
		{
			echo "!sock<br/>";
			echo $errstr."<br/>";
			return false;
		}else{
		
		
		// ������� ������ ��� ����������� �� �������
		$putline=auth.":".session_id().':'."pass";				
		fputs ($sock, $putline.""); 
		echo "auth: ".$putline."<br/>";	
		$line = fgets ($sock);
		echo "line: ".$line."<br/>";
		
		/*
		fputs ($sock, "connected\r\n"); 
		$line = fgets ($sock);
		*/
		// �������� �����
		// TODO: ������� ��������� �������� ��� ���������� ��������
		/*
		$line = fgets ($sock);
		echo "line: ".$line."<br/>";
		
		// �������� �����
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