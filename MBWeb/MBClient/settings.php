<?php		
	/*
	if (!isset($_COOKIE["ready"]))
	{
		echo "<h1>�������� ��������� cookie</h1>";
		echo "�������� �������� ������ �����";
		//$HTTP_POST_VARS["ip"];
	};
	
	//if (0) {Header("Location: settings.html");};
	session_start();
	if (isset($SESSION['ip']))
	{
		// ��� ���������������� ��������
		
	}else{
		// ��� �� ����������������
		echo '123';
	};
	*/
	session_start();
?>
<html>
<head>
	<title>���������</title>
</head>
<body>
	<form action="settings.php" method="POST" name="settings">
		������� ����� ������ � ����</br>
		<?php
			if (isset($_POST['ip']))
			{
				$_SESSION['ip'] = $_POST['ip'];
				echo "<input type=\"text\" name=\"ip\" maxlength=\"15\"".
				"size=\"16\" value=\"".$_SESSION['ip']."\"".
				"onclick=\"this.value='';\"".
				"onblur=\"if(this.value=='')this.value='".$_SESSION['ip']."';\">";
			}else{
				// ������ �� ����������, �� �� ������� �������
				if (isset($_SESSION['ip']))
				{	// ���� ������ ��� �������, �� ��������� ���������
					echo "<input type=\"text\" name=\"ip\" maxlength=\"15\"".
					"size=\"16\" value=\"".$_SESSION['ip']."\"".
					"onclick=\"this.value='';\"".
					"onblur=\"if(this.value=='')this.value='".$_SESSION['ip']."';\">";
				}else{
					// ����� ������ ������������� �������
					echo "<input type=\"text\" name=\"ip\" maxlength=\"15\"".
					"size=\"16\" value=\"IP\"".
					"onclick=\"if(this.value=='IP')this.value='';\"".
					"onblur=\"if(this.value=='')this.value='IP';\">";
				}
			}
		?>
		<?php
			if (isset($_POST['port']))
			{
				$_SESSION['port'] = $_POST['port'];
				echo "<input type=\"text\" name=\"port\" maxlength=\"5\"".
				"size=\"5\" value=\"".$_SESSION['port']."\"".
				"onclick=\"this.value='';\"".
				"onblur=\"if(this.value=='')this.value='".$_SESSION['port']."';\">";
			}else{
				// ������ �� ����������, �� �� ������� �������
				if (isset($_SESSION['port']))
				{	// ���� ������ ��� �������, �� ��������� ���������
					echo "<input type=\"text\" name=\"port\" maxlength=\"5\"".
					"size=\"5\" value=\"".$_SESSION['port']."\"".
					"onclick=\"this.value='';\"".
					"onblur=\"if(this.value=='')this.value='".$_SESSION['port']."';\">";
				}else{
					// ����� ������ ������������� �������
					echo "<input type=\"text\" name=\"port\" maxlength=\"5\"".
					"size=\"5\" value=\"����\"".
					"onclick=\"if(this.value=='����')this.value='';\"".
					"onblur=\"if(this.value=='')this.value='����';\">";
				}
			}
		?>
		</br>������� ������� �����</br>
		<?php
			if (isset($_POST['pass']))
			{
				$_SESSION['pass'] = $_POST['pass'];
				echo "<input type=\"text\" name=\"pass\" value=\""
				.$_SESSION['pass']."\"".
				"onclick=\"this.value='';\"".
				"onblur=\"if(this.value=='')this.value='".$_SESSION['pass']."';\">";
			}else{
				// ������ �� ����������, �� �� ������� �������
				if (isset($_SESSION['pass']))
				{	// ���� ������ ��� �������, �� ��������� ���������
					echo "<input type=\"text\" name=\"pass\" value=\""
					.$_SESSION['pass']."\"".
					"onclick=\"this.value='';\"".
					"onblur=\"if(this.value=='')this.value='".$_SESSION['pass']."';\">";
				}else{
					// ����� ������ ������������� �������
					echo "<input type=\"text\" name=\"pass\" value=\"������\"".
					"onclick=\"if(this.value=='������')this.value='';\"".
					"onblur=\"if(this.value=='')this.value='������';\">";
				}
			}
		?>
		</br>
		<input type="submit" value="�����������"><br/>
		<input type="button" value="������� ����������"
			onclick="javascript:header('open_sock.php');">
	</form>
</body>
</html>