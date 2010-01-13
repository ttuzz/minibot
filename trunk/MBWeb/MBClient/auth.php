<?php
	/* пока что не понятно, что делать, если клиент пришел через прокси 
	 * ибо пускать данные по 80 порту - верх извращенства.
	 * страница реализует диалог запроса данных для авторизации на сервере
	 * также сюда происходит возврат при ошибке параметров сокета */
	
	require "socks.php";	//контейнер процедур работы с сервером
	
	if (isset($_POST['ip']))	// если пользователь подтвердил ввод
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
		// в функцию проверки заношу данные из _post
		// проверка валидности юзера с помощью функциии из open_sock.php
		// $err = some_func();
		// удаляю остатки предыдущих сессий, если были.
		session_start();	// запускаю сессию
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
	<title>Авторизация</title>
</head>

<body>
	<?php	//вывожу ошибку, если есть. см. код выше или open_sock.php
		echo $err;
	?>
	<form action="auth.php" method="POST" name="auth">
		Введите адрес машины и порт</br>
		<?php
			echo "<input type=\"text\" name=\"ip\" maxlength=\"15\"".
				"size=\"16\" value=\"188.17.88.20\"".
				"onclick=\"if(this.value=='IP')this.value='';\"".
				"onblur=\"if(this.value=='')this.value='IP';\"> ";
			echo "<input type=\"text\" name=\"port\" maxlength=\"5\"".
				"size=\"5\" value=\"5000\"".
				"onclick=\"if(this.value=='Порт')this.value='';\"".
				"onblur=\"if(this.value=='')this.value='Порт';\">";
		?>
		</br>Введите кодовое слово</br>
		<?php
			echo "<input type=\"text\" name=\"pass\" value=\"Пароль\"".
				"onclick=\"if(this.value=='Пароль')this.value='';\"".
				"onblur=\"if(this.value=='')this.value='Пароль';\">";
		?>
		</br>
		<input type="submit" value="Подтвердить"><br/>
	</form>
</body>
</html>