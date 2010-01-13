<?php		
	/*
	if (!isset($_COOKIE["ready"]))
	{
		echo "<h1>Включите поддержку cookie</h1>";
		echo "возможна неверная работа сайта";
		//$HTTP_POST_VARS["ip"];
	};
	
	//if (0) {Header("Location: settings.html");};
	session_start();
	if (isset($SESSION['ip']))
	{
		// уже зарегистрировано значение
		
	}else{
		// ещё не зарегистрированы
		echo '123';
	};
	*/
	session_start();
?>
<html>
<head>
	<title>Настройки</title>
</head>
<body>
	<form action="settings.php" method="POST" name="settings">
		Введите адрес машины и порт</br>
		<?php
			if (isset($_POST['ip']))
			{
				$_SESSION['ip'] = $_POST['ip'];
				echo "<input type=\"text\" name=\"ip\" maxlength=\"15\"".
				"size=\"16\" value=\"".$_SESSION['ip']."\"".
				"onclick=\"this.value='';\"".
				"onblur=\"if(this.value=='')this.value='".$_SESSION['ip']."';\">";
			}else{
				// пришли по обновлению, не по нажатию клавиши
				if (isset($_SESSION['ip']))
				{	// если сессия уже создана, то подгружаю параметры
					echo "<input type=\"text\" name=\"ip\" maxlength=\"15\"".
					"size=\"16\" value=\"".$_SESSION['ip']."\"".
					"onclick=\"this.value='';\"".
					"onblur=\"if(this.value=='')this.value='".$_SESSION['ip']."';\">";
				}else{
					// иначе вывожу пояснительные записки
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
				// пришли по обновлению, не по нажатию клавиши
				if (isset($_SESSION['port']))
				{	// если сессия уже создана, то подгружаю параметры
					echo "<input type=\"text\" name=\"port\" maxlength=\"5\"".
					"size=\"5\" value=\"".$_SESSION['port']."\"".
					"onclick=\"this.value='';\"".
					"onblur=\"if(this.value=='')this.value='".$_SESSION['port']."';\">";
				}else{
					// иначе вывожу пояснительные записки
					echo "<input type=\"text\" name=\"port\" maxlength=\"5\"".
					"size=\"5\" value=\"Порт\"".
					"onclick=\"if(this.value=='Порт')this.value='';\"".
					"onblur=\"if(this.value=='')this.value='Порт';\">";
				}
			}
		?>
		</br>Введите кодовое слово</br>
		<?php
			if (isset($_POST['pass']))
			{
				$_SESSION['pass'] = $_POST['pass'];
				echo "<input type=\"text\" name=\"pass\" value=\""
				.$_SESSION['pass']."\"".
				"onclick=\"this.value='';\"".
				"onblur=\"if(this.value=='')this.value='".$_SESSION['pass']."';\">";
			}else{
				// пришли по обновлению, не по нажатию клавиши
				if (isset($_SESSION['pass']))
				{	// если сессия уже создана, то подгружаю параметры
					echo "<input type=\"text\" name=\"pass\" value=\""
					.$_SESSION['pass']."\"".
					"onclick=\"this.value='';\"".
					"onblur=\"if(this.value=='')this.value='".$_SESSION['pass']."';\">";
				}else{
					// иначе вывожу пояснительные записки
					echo "<input type=\"text\" name=\"pass\" value=\"Пароль\"".
					"onclick=\"if(this.value=='Пароль')this.value='';\"".
					"onblur=\"if(this.value=='')this.value='Пароль';\">";
				}
			}
		?>
		</br>
		<input type="submit" value="Подтвердить"><br/>
		<input type="button" value="Поднять соединение"
			onclick="javascript:header('open_sock.php');">
	</form>
</body>
</html>