package Fmpv;

sub parse_duration {
	my ($str) = @_;
	my $dur = substr $str,8,7;
	return $dur;
}

sub parse_position {
	my($str) = @_;
	my $pos = substr $str,8,5;
	return $pos;
}

1;
