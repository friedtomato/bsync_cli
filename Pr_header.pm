package Pr_header;

$PR_CONF->{"sharp_4"}->{'port'} = "/dev/ttyUSB0";
$PR_CONF->{"sharp_4"}->{'baudrate'} = 9600;
$PR_CONF->{"sharp_4"}->{'databits'} = 8;
$PR_CONF->{"sharp_4"}->{'parity'} = "none";
$PR_CONF->{"sharp_4"}->{'stopbits'} = 1;
$PR_CONF->{"sharp_4"}->{'pwron'} = "\nPOWR   1\n";
$PR_CONF->{"sharp_4"}->{'pwroff'} = "\nPOWR   0\n";
$PR_CONF->{"sharp_4"}->{'status'} = "\nPOWR????\n";
# no white characters
$PR_CONF->{"sharp_4"}->{'pwron_return'} = "ERROK";
$PR_CONF->{"sharp_4"}->{'pwroff_return'} = "ERROK";
$PR_CONF->{"sharp_4"}->{'status_return'} = "ERR   0";

$PR_CONF->{"benq_611c"}->{'port'} = "/dev/ttyUSB0";
$PR_CONF->{"benq_611c"}->{'baudrate'} = 115200;
$PR_CONF->{"benq_611c"}->{'databits'} = 8;
$PR_CONF->{"benq_611c"}->{'parity'} = "none";
$PR_CONF->{"benq_611c"}->{'stopbits'} = 1;
$PR_CONF->{"benq_611c"}->{'pwron'} = "\x06\x14\x00\x03\x00\x34\x11\x00\x5c";
$PR_CONF->{"benq_611c"}->{'pwroff'} = "\x06\x14\x00\x03\x00\x34\x11\x01\x5d";
$PR_CONF->{"benq_611c"}->{'status'} = "";

$PR_CONF->{"benq_741"}->{'port'} = "/dev/ttyUSB0";
$PR_CONF->{"benq_741"}->{'baudrate'} = 115200;
$PR_CONF->{"benq_741"}->{'databits'} = 8;
$PR_CONF->{"benq_741"}->{'parity'} = "none";
$PR_CONF->{"benq_741"}->{'stopbits'} = 1;
$PR_CONF->{"benq_741"}->{'pwron'} = "*pow=on#";
$PR_CONF->{"benq_741"}->{'pwroff'} = "*pow=off#";
$PR_CONF->{"benq_741"}->{'status'} = "*pow=?#";
# no white characters
$PR_CONF->{"benq_741"}->{'pwron_return'} = "*pow=on#*POW=ON#";
$PR_CONF->{"benq_741"}->{'pwroff_return'} = "*pow=off#*POW=OFF#";
$PR_CONF->{"benq_741"}->{'status_return'} = "*pow=?#*POW=ON/OFF#";

$PR_CONF->{"optoma"}->{'port'} = "/dev/ttyUSB0";
$PR_CONF->{"optoma"}->{'baudrate'} = 9600;
$PR_CONF->{"optoma"}->{'databits'} = 8;
$PR_CONF->{"optoma"}->{'parity'} = "none";
$PR_CONF->{"optoma"}->{'stopbits'} = 1;
$PR_CONF->{"optoma"}->{'pwron'} = "\x7e\x30\x30\x30\x30\x20\x31\x0d";
$PR_CONF->{"optoma"}->{'pwroff'} = "\x7e\x30\x30\x30\x30\x20\x30\x0d";
$PR_CONF->{"optoma"}->{'status'} = "\x7e\x30\x30\x31\x32\x34\x20\x31\x0d";
# no white characters
$PR_CONF->{"optoma"}->{'pwron_return'} = "";
$PR_CONF->{"optoma"}->{'pwroff_return'} = "";
$PR_CONF->{"optoma"}->{'status_return'} = "";




1;
