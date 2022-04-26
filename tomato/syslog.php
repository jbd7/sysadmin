<!--

//
// Log parser for FreshTomato router
// To be installed on nginx's document root 
// by jbd7

// Credit: https://stackoverflow.com/a/10494801

-->

<!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="utf-8">
		<meta http-equiv="content-type" content="text/html;charset=utf-8">

<script>

			function resetStartDate() {
				// countDownDate = Date.now();
				localStorage.removeItem('startDate');
			}

			function setStartDate() {
				countDownDate = new Date();
				localStorage.setItem('startDate', countDownDate);
			}

			var countDownDate = localStorage.getItem('startDate');
			if (countDownDate) {
			    countDownDate = new Date(countDownDate);
			} else {
			    setStartDate();
			}

			// Update the count down every 1 second
			var x = setInterval(function() {

			    // Get todays date and time
			    var now = new Date().getTime();

			    // Find the distance between now an the count down date
			    var distance = now - countDownDate.getTime();

			    // Time calculations for seconds
			    var days = Math.floor(distance / (1000 * 60 * 60 * 24));
			    var hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
			    var minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
			    var seconds = Math.floor((distance % (1000 * 60)) / 1000);

			    // Output the result in an element with id="demo"
			    document.getElementById("timeup").innerHTML = minutes * 60 + seconds;
			}, 1000);

</script>

	<title>FreshTomato log, reversed</title>
	</head>
	<body onLoad="setStartDate();">

		It is <?php echo date("H:i:sa") ?> 
		<button onClick="window.location.reload();">Refresh Page</button>
		Loaded for <div style="display: inline" id="timeup"></div> seconds.	
		<input type="checkbox" onclick="toggleAutoRefresh(this);" id="reloadCB"> Auto Refresh 5s
		<button onClick="setStartDate();">setStartDate</button>

	
<script>
			var reloading;

			function checkReloading() {
			    if (window.location.hash=="#autoreload") {
				reloading=setTimeout("window.location.reload();", 5000);
				document.getElementById("reloadCB").checked=true;
			    }
			}

			function toggleAutoRefresh(cb) {
			    if (cb.checked) {
				window.location.replace("#autoreload");
				reloading=setTimeout("window.location.reload();", 5000);
			    } else {
				window.location.replace("#");
				clearTimeout(reloading);
			    }
			}

			window.onload=checkReloading;

</script>




<?php


			class ReverseFile implements Iterator
			{
			    const BUFFER_SIZE = 4096;
			    const SEPARATOR = "\n";

			    public function __construct($filename)
			    {
				$this->_fh = fopen($filename, 'r');
				$this->_filesize = filesize($filename);
				$this->_pos = -1;
				$this->_buffer = null;
				$this->_key = -1;
				$this->_value = null;
			    }

			    public function _read($size)
			    {
				$this->_pos -= $size;
				fseek($this->_fh, $this->_pos);
				return fread($this->_fh, $size);
			    }

			    public function _readline()
			    {
				$buffer =& $this->_buffer;
				while (true) {
				    if ($this->_pos == 0) {
					return array_pop($buffer);
				    }
				    if (count($buffer) > 1) {
					return array_pop($buffer);
				    }
				    $buffer = explode(self::SEPARATOR, $this->_read(self::BUFFER_SIZE) . $buffer[0]);
				}
			    }

			    public function next()
			    {
				++$this->_key;
				$this->_value = $this->_readline();
			    }

			    public function rewind()
			    {
				if ($this->_filesize > 0) {
				    $this->_pos = $this->_filesize;
				    $this->_value = null;
				    $this->_key = -1;
				    $this->_buffer = explode(self::SEPARATOR, $this->_read($this->_filesize % self::BUFFER_SIZE ?: self::BUFFER_SIZE));
				    $this->next();
				}
			    }

			    public function key() { return $this->_key; }
			    public function current() { return $this->_value; }
			    public function valid() { return ! is_null($this->_value); }
			}

                        function printFile($f) {
                                foreach ($f as $line) {

                                        $color = "";
                                        if (preg_match("/daemon\.info dnsmasq/", $line)) {$color = "gray";}
                                        if (preg_match("/cron\.info/i", $line)) {$color = "blue";}
                                        if (preg_match("/(is 0\.0\.0\.0|is NODATA)/", $line)) {$color = "red";}

                                        echo '<span style="color:' . $color . '">' . $line . '</span>';
                                        echo "<br />";
                                }
                        }


                        $filename = "/var/log/messages";

                        // Printing the syslog
                        $f = new ReverseFile($filename);
                        printFile($f);

                        // Printing the logrotated syslogs, if any
                        for ($i = 0; $i <= 4; $i++) {
                                if (file_exists($filename.".".$i)) {
                                        echo "FOUND " . $filename.".".$i." ";
                                        $f = new ReverseFile($filename.".".$i);
                                        printFile($f);
                                }
                        }

                        echo "<br /> END OF FILE. Loaded at " . date("H:i:sa") ;


?>


	</body>

</html>
