<?php
	/* ���� ��� �� �������, ��� ������, ���� ������ ������ ����� ������ 
	 * ��� ������� ������ �� 80 ����� - ���� ������������.
	 * �������� ��������� ������ ������� ������ ��� ����������� �� �������
	 * ����� ���� ���������� ������� ��� ������ ���������� ������ */
	
	require "socks.php";	//��������� �������� ������ � ��������
	
	if (isset($_POST['ip']))	// ���� ������������ ���������� ����
	{
		/*
		$_SESSION['ip'] = $_POST['ip'];
		$_SESSION['port'] = $_POST['port'];
		$_SESSION['pass'] = $_POST['pass'];
		$_SESSION['pass_valid'] = false;
			if (isset($_SESSION['ip'])	){ unset($_SESSION['ip']);   };
			if (isset($_SESSION['port'])){ unset($_SESSION['port']); };
			if (isset($_SESSION['pass'])){ unset($_SESSION['pass']); };
			if (isset($_SESSION['pass_valid'])){ unset($_SESSION['pass_valid']); };
			session_destroy();	
		*/
		// � ������� �������� ������ ������ �� _post
		// �������� ���������� ����� � ������� �������� �� open_sock.php
		// $err = some_func();
		// ������ ������� ���������� ������, ���� ����.
		session_start();	// �������� ������
		$pass_valid = user_validate(
			$_POST['ip'], 
			$_POST['port'], 
			$_POST['pass'],
			$errno, $errstr, 5);
		if ($pass_valid === true) 
		{
			$_SESSION['ip'] = $_POST['ip'];
			$_SESSION['port'] = $_POST['port'];
			$_SESSION['lines'] = array();
			Header("Location: session.php");
		};
	};	
?>
<html>
<head>
	<title>�����������</title>
</head>

<body>
	<?php	//������ ������, ���� ����. ��. ��� ���� ��� open_sock.php
		echo $err;
	?>
	<form action="auth.php" method="POST" name="auth">
		������� ����� ������ � ����</br>
		<?php
			echo "<input type=\"text\" name=\"ip\" maxlength=\"15\"".
				"size=\"16\" value=\"188.17.88.20\"".
				"onclick=\"if(this.value=='IP')this.value='';\"".
				"onblur=\"if(this.value=='')this.value='IP';\"> ";
			echo "<input type=\"text\" name=\"port\" maxlength=\"5\"".
				"size=\"5\" value=\"5000\"".
				"onclick=\"if(this.value=='����')this.value='';\"".
				"onblur=\"if(this.value=='')this.value='����';\">";
		?>
		</br>������� ������� �����</br>
		<?php
			echo "<input type=\"text\" name=\"pass\" value=\"������\"".
				"onclick=\"if(this.value=='������')this.value='';\"".
				"onblur=\"if(this.value=='')this.value='������';\">";
		?>
		</br>
		<input type="submit" value="�����������"><br/>
	</form>
</body>
</html>