<?php
	// ��������� �� � ���� ����� ������ ������. @ - �������� ���������� ������ ������
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
		
	// ������� �����
	// TODO: ������� ��������� �������� ��� ���������� ��������
	$line = fgets ($sock);

	// �������� �����
	fclose($sock);
	
	echo $line;
?>