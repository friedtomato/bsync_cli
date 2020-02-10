package Fwsocket;

use IO::Interface::Simple;

my $IF_WLAN_NAME = "wlan0";
my $IF_WLAN_IP = "un";

sub get_wlan_ip {
	my $if_wlan = IO::Interface::Simple->new($IF_WLAN_NAME);
	$IF_WLAN_IP = $if_wlan->address;
	undef $if_wlan;
	print "wlan0 - ".$IF_WLAN_IP."\n";
	return $IF_WLAN_IP;
}

1;
