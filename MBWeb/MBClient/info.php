<html>
<head>
<title>info</title>
</head>

<body>
	<?php
		if ($_POST['pass'] == "*rhemn*")
		{
			phpinfo();
		};
	?>
	<form action="info.php" name="info" method="POST">
		<input type="text" name="pass">
		<input type="submit" value="Отправить">
	</form>
</body>

</html>