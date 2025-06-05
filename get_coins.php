<?php
// Enable error reporting for debugging
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Redirect to coin_handler.php with the 'get' action
header('Location: coin_handler.php?action=get');
exit;
?>
