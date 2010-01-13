<?php
	/* �������� ������� �������� ip, �����
	 * � ����� ����������� �� �������
	 * !!!��������� �����!!!
	 */
	 
	// ������ ������ �����������
	//	������: "#AUTH:session_id():pass"
	//	������: "#VALID" or "#INVALID"
	
	// ������ ������ ������� ������
	//	������: "#REQUEST:session_id()"
	//	������: "#VALID:������" or "#INVALID"
	
	// ������ ������ �������� ������
	//	������: "#SEND:session_id():������"
	//	������: "#VALID" or "#INVALID"
	
	define("auth", "#AUTH");
	define("request", "#REQUEST");
	define("send", "#SEND");
	define("valid", "#VALID");
	define("invalid", "#INVALID");
	
	function user_validate($ip, $port, $pass, &$errno, &$errstr, $timeout=5)
	{		
		// ��������� �� � ���� ����� ������ ������. @ - �������� ���������� ������ ������
		$sock = @fsockopen($ip, $port, $errno, $errstr, $timeout);
		if (!$sock)
		{
			fclose($sock);
			echo "!sock!!!";
			return false;
		};
		
		// ������� ������ ��� ����������� �� �������
		fputs($sock, auth.':'.session_id().':'.$pass."\r\n");
		
		// �������� �����
		// TODO: ������� ��������� �������� ��� ���������� ��������
		$line = fgets ($sock);

		// �������� �����
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
		// ������ ������. @ - �������� ���������� ������ ������
		$sock = @fsockopen ($ip, $port, $errno, $errstr, $timeout);
		if (!$sock)
		{
			echo $errsr;
			return false;
		};
		
		// ������� ������ ������
		fputs($sock, request.':'.session_id()."\r\n");
		
		// ������� �����
		// TODO: ������� ��������� �������� ��� ���������� ��������
		$line = fgets ($sock);
		// TODO: ������� ������ ����(��� ����������/������������) �� ������
		
		// �������� �����
		fclose($sock);
		
		return $line;
	};
	
	function send_str($string, $ip, $port, &$errno, &$errstr, $timeout=5)
	{		
		// ������ ������. @ - �������� ���������� ������ ������
		$sock = @fsockopen ($ip, $port, $errno, $errstr, $timeout);
		if (!$sock)
		{
			fclose($sock);
			return false;
		};
		
		// ������� ������ ������ �� �������
		fputs($sock, send.':'.session_id().':'.$string."\r\n");
		
		// �������� �����
		// TODO: ������� ��������� �������� ��� ���������� ��������
		$line = fgets ($sock);
		
		// �������� �����
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