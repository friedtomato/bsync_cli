package Fsocket;
use IO::Socket::INET;
use IO::Socket::UNIX;
use IO::Select;

my $BCAST_SOCKET;
my $LISTEN_SOCKET;


my $MPV_SOCKET;
my $BCASTLI_SOCKET;
my $WRITE_SOCKET;
my $NETLOG_SOCKET;
my $NETLOG_IP;
my $NETLOG_PORT;

sub bcast_socket {
  my ($ip,$port,$type) = @_;

  my $bcast_socket;

  # server
  if($type eq "srv"){
    $bcast_socket = new IO::Socket::INET (
  	PeerPort	=> $port,
	PeerAddr	=> inet_ntoa(INADDR_BROADCAST),
	Proto		=> 'udp',
	LocalAddr	=> $ip,
	# Type		=> SOCK_DGRAM,
	Broadcast	=>1) or die "[SRV-EXIT]Cannot bind bcast socket: $@\n";
    $BCAST_SOCKET = $bcast_socket;
  }
  # client
  if($type eq "cli"){
    $bcast_socket = new IO::Socket::INET (
    	LocalPort	=> $port,
	# Type 		=> SOCK_DGRAM,
	Blocking	=> 0,
	Proto		=> 'udp') or die "[CLI-EXIT]Cannot bind bcast socket: $@\n";	    
    $BCASTLI_SCOKET = $bcast_socket;
  }
  return $bcast_socket;
}

sub mpv_socket {
  my ($sock_path) = @_;
  my $max_loop = 2000;
  my $loop = 0;
  my $mpv_socket;
  while((!$mpv_socket) and ($loop <= $max_loop)){
    $mpv_socket = IO::Socket::UNIX->new (
  	  Type	=> SOCK_STREAM,
	  Peer	=> $sock_path
    ); 
#	    or die "Cannot bind the MPV socket $sock_path: $@\n";
    $loop++;
    if(!$mpv_socket){
	    #print "[L=$loop] Cannot bind the MPV socket $sock_path: $@\n";
    }
  }
  if(!$mpv_socket){
    die "[EXIT] Cannot bind the MPV socket $sock_path: $@\n";
  }
  else{
	  #print "MPV socket open\n";
  }
  $MPV_SOCKET = $mpv_socket;
  return $mpv_socket;
}

sub listen_socket {
  my ($ip,$port) = @_;

  my $listen_socket = IO::Socket::INET->new (
    LocalHost	=> $ip,
    LocalPort	=> $port,
    Proto	=> 'tcp',
    Listen	=> 20,
    Reuse	=> 1) or die "[EXIT] Cannot bind listen socket: $@\n";
  $LISTEN_SOCKET = $listen_socket; 
  return $listen_socket;
}

sub write_socket {
  my ($ip, $port) = @_;
  print "enterin write_socket ($ip,$port)\n"; 
  my $write_socket = IO::Socket::INET->new (
  	PeerHost	=> $ip,
	PeerPort	=> $port,
	Proto		=> 'tcp') or die "[EXIT] Cannot bind write socket ($ip,$port): $!\n";
  print "after socket->new \n";
  $WRITE_SOCKET = $write_socket;
  return $write_socket; 
}

sub netlog_socket {
  my ($ip, $port) = @_;
  my $max_loop = 200;
  my $loop = 0;
  my $netlog_socket;
  while((!$netlog_socket) and ($loop <= $max_loop)){
    $netlog_socket = IO::Socket::INET->new (
	PeerHost	=> $ip,
	PeerPort	=> $port,
	Proto		=>'tcp');
    if(!$netlog_socket){
	    #print "[L=$loop] Cannot bind netlog socket ($ip, $port): $!\n";
    }
    #sleep 1;
    $loop++;
  }       
  if((!defined($netlog_socket))){
    die "[EXIT] Cannot bind netlog socket ($ip, $port): $!\n";
  }
  else{
	  #print "Netlog socket open\n";
  }
  $NETLOG_SOCKET = $netlog_socket;
  $NETLOG_IP = $ip;
  $NETLOG_PORT = $port;
  return $netlog_socket;
}

sub netlog_item {
  my ($netlog_ip,$netlog_port,$mesg) = @_;
  
  my $sock = netlog_socket($netlog_ip,$netlog_port);
  $sock->send($mesg); 
  shutdown($sock,1);
  $sock->close();
  undef($sock);
  undef($NETLOG_SOCKET);
}

sub send_bcast {
  my ($mesg) = @_;

  $BCAST_SOCKET->send($mesg) or die "Bcast failed: $!\n";
  return 1;
}

sub get_comm {
  my ($socket,$cycles,$timeout) = @_;
  my $bcast;

  my $done = $cycles;
  my $sel = IO::Select->new($socket);
  while($done){
    my @ready = $sel->can_read($timeout);
    if(scalar @ready){
      $socket->recv($bcast,1024);
      if(defined($bcast)){
	      #Flog::item_flog("[GC] received $bcast");
        $done = 0;
      }
    }
    else{
      $done--;
    }
  }
  $sel->remove($socket);
  undef($sel);
  return $bcast;
}


sub close_socket {
  my ($socket) = @_;

  shutdown($socket,1);
  $socket->close();
  undef($socket);
}

1;
