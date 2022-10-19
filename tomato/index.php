<a href="syslog.php">syslog</a>
<br /><br />

<a href="phpinfo.php">phpinfo</a>
<a href="index.html">nginx homepage</a>
<html>
        <head>

        <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>

        </head>

<body>        

        <?php
           function prep2print($filename) {
                return nl2br(file_get_contents($filename));
            }
        ?>

<h1><a href="syslog.php">syslog</a></h1>
<br /><br />

<h3>
</h3>
<br /><br />

<?php
echo 'User IP Address - '.$_SERVER['REMOTE_ADDR'].'</BR>';
echo 'Server Local IP Address - '.$_SERVER['SERVER_ADDR'].'</BR>';
echo 'Server External IP Address - '.file_get_contents("http://ipecho.net/plain").'</BR>';
?>

<hr5>
<a href="phpinfo.php">phpinfo</a>
<a href="index2.html">nginx homepage</a>
</h5>
<br /><br />

<h4>hosts.dnsmasq</h4>
        <?php
           echo prep2print('/tmp/etc/hosts.dnsmasq');
        ?>


</body>
</html>
