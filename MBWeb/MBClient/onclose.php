<?php
	/***
	 * высвобожждает ресурсы и завершает сессию. 
	 * вызывается при деактивации юзера(log off)
	 */
	session_start();
	
	unset($_SESSION['ip']);
	unset($_SESSION['port']);
	unset($_SESSION['lines']);
	
	session_destroy();
	
	echo "this is onclose event!";
?>