package Fpar;

sub parse_par_hostname {
  my ($par,$cliname) = @_;
  #print $par."\n";
  my $num = split ',',$par;
  #print "num ".$num."\n";
  if($num > 1){
    my @list_par = split ',',$par;
    foreach my $item (@list_par){
	    print "$cliname x $item\n";
      if($item eq $cliname){
	# i am on the list, run the bcast
	print "ret 1\n";
        return 1;
      }
    }
    #list of clients present, but not with me on it
    print "ret 0\n";
    return 0;
  }
  #no client names listed, run the bcast
  if(($par eq "go") or ($par eq $cliname)){
	  print "ret 2\n";
    return 2;
  }
  else{
	  print "ret 0\n";
    return 0;
  }
}

1;
