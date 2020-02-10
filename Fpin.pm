package Fpin;

use RPi::Pin;
use RPi::Const qw(:all);

my $HS_PIN18 = 18;
my $HS_PIN23 = 23;
my $PIN18;
my $PIN23;



sub init_hs_pin {
  my ($init_value) = @_;
  my $pin1 = RPi::Pin->new($HS_PIN18);
  my $pin2 = RPi::Pin->new($HS_PIN23);
  my $ret = "";
  if(!defined($pin1)){
    print "cannot initiate PIN($HS_PIN18): $!";
    $ret = "P18[NOK]";
  }
  else{
    $ret = "P18[OK]";
  }
  if(!defined($pin2)){
    print "cannot initiate PIN($HS_PIN23): $!";
    $ret = $ret."P23[NOK]";
  }
  else{
    $ret = $ret."P23[OK]";
  }
  $pin1->mode(OUTPUT);
  $pin2->mode(OUTPUT);
  $pin1->write($init_value);
  $pin2->write($init_value);
  $PIN18 = $pin1;
  $PIN23 = $pin2;
  return $ret;
}

sub up_hs_pin {
  my $ret = "";
  if(!defined($PIN18)){
    print "[UP] PIN18 var is not defined: $!";
    $ret = "P18U[NOK]";
  }
  else{
    $ret = "P18U[OK]";
  }

  if(!defined($PIN23)){
    print "[UP] PIN23 var is not defined: $!";
    $ret = $ret."P23U[NOK]";
  }
  else{
    $ret = $ret."P23U[OK]";
  }
  $PIN18->write(HIGH);
  $PIN23->write(HIGH);
  return $ret;
}

sub down_hs_pin {
  my $ret = "";
  if(!defined($PIN18)){
    print "[DOWN] PIN18 var is not defined: $!";
    $ret = "P18[NOK]";
  }
  else{
    $ret = "P18[OK]";
  }
  if(!defined($PIN23)){
    print "[DOWN] PIN23 var is not defined: $!";
    $ret = $ret."P23[NOK]";
  }
  else{
    $ret = $ret."P23[OK]";
  }
  $PIN18->write(LOW);
  $PIN23->write(LOW);
  return $ret;
}

sub del_hs_pin {
  undef $PIN18;
  undef $PIN23;
}


1;
