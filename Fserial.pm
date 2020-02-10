package Fserial;

use Device::SerialPort;
use Pr_header;

sub set_prj_on {
  my ($prj_name,$max_loop) = @_;
  my $port = Device::SerialPort->new($Pr_header::PR_CONF->{"$prj_name"}->{'port'});
  $port->baudrate($Pr_header::PR_CONF->{"$prj_name"}->{'baudrate'});
  $port->databits($Pr_header::PR_CONF->{"$prj_name"}->{'databits'});
  $port->parity($Pr_header::PR_CONF->{"$prj_name"}->{'parity'});
  $port->stopbits($Pr_header::PR_CONF->{"$prj_name"}->{'stopbits'});
  my $str_on = $Pr_header::PR_CONF->{"$prj_name"}->{'pwron'};
  $port->write($str_on);

  my $start = 1;
  my $return = "";
  my $end = 0;
  my $counter = 0;
  while(!$end){
    $counter++;
    if($counter == $max_loop){
	    $return = $return."[expired]";
	    $end = 1;
    }
    my ($num,$char) = $port->read(1);
    if ($num == 0){
	    next;
    }
    #return
    if(ord($char) == 13){
	    if($return eq $Pr_header::PR_CONF->{"$prj_name"}->{'pwron_return'}){
		    #print "return = *$return*\n";
		    $end = 1;
	    }
	    
    }
    # regular char
    else {
	    $return = $return.$char;
    }
  }
  $port->close;
  return $return;
}

sub set_prj_off {
  my ($prj_name,$max_loop) = @_;
  my $port = Device::SerialPort->new($Pr_header::PR_CONF->{"$prj_name"}->{'port'});
  $port->baudrate($Pr_header::PR_CONF->{"$prj_name"}->{'baudrate'});
  $port->databits($Pr_header::PR_CONF->{"$prj_name"}->{'databits'});
  $port->parity($Pr_header::PR_CONF->{"$prj_name"}->{'parity'});
  $port->stopbits($Pr_header::PR_CONF->{"$prj_name"}->{'stopbits'});
  my $str_off = $Pr_header::PR_CONF->{"$prj_name"}->{'pwroff'};
  $port->write($str_off);

  my $start = 1;
  my $return = "";
  my $end = 0;
  my $counter = 0;
  while(!$end){
    $counter++;
    if($counter == $max_loop){
	    $return = $return."[expired]";
	    $end = 1;
    }
    my ($num,$char) = $port->read(1);
    if ($num == 0){
	    next;
    }
    #return
    if(ord($char) == 13){
	    #print $return."\n";
	    if($return eq $Pr_header::PR_CONF->{"$prj_name"}->{'pwroff_return'}){
		    #print "return = *$return*\n";
		    $end = 1;
	    }
    }
    # regular char
    else {
	    $return = $return.$char;
    }
  }
  $port->close;
  return $return;
}


sub check_prj_return {
  my($prj_name,$return) = @_;
  if ($return eq $Pr_header::PR_CONF->{"$prj_name"}->{'return'}){
	  return 1;
  }
  else{
	  return 0;
  }
}


sub get_prj_status {
  my ($prj_name,$max_loop) = @_;
  my $port = Device::SerialPort->new($Pr_header::PR_CONF->{"$prj_name"}->{'port'});
  $port->baudrate($Pr_header::PR_CONF->{"$prj_name"}->{'baudrate'});
  $port->databits($Pr_header::PR_CONF->{"$prj_name"}->{'databits'});
  $port->parity($Pr_header::PR_CONF->{"$prj_name"}->{'parity'});
  $port->stopbits($Pr_header::PR_CONF->{"$prj_name"}->{'stopbits'});
  my $str_status = $Pr_header::PR_CONF->{"$prj_name"}->{'status'};
  $port->write($str_status);

  my $start = 1;
  my $return = "";
  my $end = 0;
  my $counter = 0;
  while(!$end){
    $counter++;
    if($counter == $max_loop){
	    $return = $return."[expired]";
	    
	    $end = 1;
    }
    my ($num,$char) = $port->read(1);
    if ($num == 0){
	    next;
    }
    #return
    if(ord($char) == 13){
	    if($return eq $Pr_header::PR_CONF->{"$prj_name"}->{'status_return'}){
		    #print "return = *$return*\n";
		    $end = 1;
	    }
	    #print "return = *$return*\n";
    }
    # regular char
    else {
	    $return = $return.$char;
	    chomp $return;
    }
  }
  $port->close;
  chomp $return;
  
  return $return;

}

1;
