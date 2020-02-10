package Fav;

sub set_volume {
  my($args_string,$volume) = @_;

  my $ntime = time();
  #Flog::item_flog("[SV] setting volume $volume");
  my @args = ("$args_string $volume");
  system(@args) == 0 or die "system @args failed: $?\n";
}



1;
