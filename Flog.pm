package Flog;

#require Exporter;
#@ISA = qw(Exporter);
#@EXPORT = qw(item_flow);

#OLOG;
#FLOG;

use Fsocket;
use Fwsocket;
use Fstatus;

my $PREFIX_CLIENT;
my $PREFIX_HOST;
my $NETLOG_FLAG = 0;
my $NETLOG_IP = "192.168.0.1";
my $NETLOG_PORT = 8888;
my $IF_WLAN_IP;

sub open_olog {
  my ($logfile) = @_;
  open OLOG, ">$logfile" or die "Cannot open olog: $!\n";
  OLOG->autoflush(1);

}

sub open_flog {
  my ($logfile,$hostname,$cliname,$net_flag,$srv_ip,$net_port) = @_;
  open FLOG,">$logfile" or die "Cannot open flog: $!\n";
  FLOG->autoflush(1);
  $PREFIX_CLIENT = $cliname;
  $PREFIX_HOST = $hostname;
  $NETLOG_FLAG = $net_flag;
  $NETLOG_IP = $srv_ip;
  $NETLOG_PORT = $net_port;
  $IF_WLAN_IP = Fwsocket::get_wlan_ip();
}


sub item_flog {
  my ($item) = @_;

  Fstatus::get_status();
  my $thro = Fstatus::parse_thro();
  my $temp = Fstatus::parse_temp();
  my $volts = Fstatus::parse_volts();
  #my $str = "$IF_WLAN_IP/$PREFIX_HOST|$PREFIX_CLIENT|$ntime|NL=$NETLOG_FLAG~$item\n";
  my $ntime = time();
  my $str = "$IF_WLAN_IP/$PREFIX_HOST|$PREFIX_CLIENT|$ntime|NL=$NETLOG_FLAG~$temp|$thro|$volts~$item\n";
  print FLOG "$IF_WLAN_IP/$PREFIX_HOST|$PREFIX_CLIENT|$ntime|NL=$NETLOG_FLAG~$temp|$thro|$volts~$item\n";
  
  if ($NETLOG_FLAG){
    Fsocket::netlog_item($NETLOG_IP,$NETLOG_PORT,$str);
  }

}

sub item_olog {
  my ($item) = @_;

  my $ntime = time();
  print OLOG "$ntime $item\n";

}

sub close_olog {
  close OLOG;
}

sub close_flog {
  close FLOG;
}

1;
