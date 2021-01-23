#!/usr/bin/env perl

use strict;
use warnings;

use utf8;
binmode STDOUT, ":utf8";

use lib '.';
use XMLiTunes;

my $bitlates = {}; # $bitlates->{artist}->{album}->{bitlate} = 1;

if ( ! $ARGV[0] ) {
	print STDERR "usage: " . __FILE__ . " iTunes_Library_Exported.xml\n";
	exit(0);
}

my $xmlitunes = XMLiTunes->new();
$xmlitunes->parse_file($ARGV[0]);
print STDERR "XML loaded.\n";

my $cnt = 0;
$xmlitunes->tracks( sub{
	my $track = shift;
	eval {
		my $artist = $track->get('Album Artist');
		if ( ! $artist ) {
			if ( $track->has('Compilation') ) {
				$artist = '<Complation>';
			} else {
				$artist = $track->get('Artist');
			}
		}
		my $album   = $track->get('Album');
		my $bitlate = $track->get('Bit Rate');
		$bitlates->{$artist} = {} if ! exists $bitlates->{$artist};
		$bitlates->{$artist}->{$album} = {} if ! exists $bitlates->{$artist}->{$album};
		$bitlates->{$artist}->{$album}->{$bitlate} = 1;
	};
	if ($@) {
		print STDERR $@, "\n";
	}
	$cnt++;
	print STDERR "$cnt\n\x1BM";
}, sub{
	my $count = shift;
	print STDERR "total $count tracks found.\n";
});

print join '', map {
	my $artist = $_;
	join '', map {
		my $album = $_;
		my $bitlate = join ' ', sort {$b cmp $a} keys %{ $bitlates->{$artist}->{$album} };
		$artist =~ s/\t/ /g;
		$album =~ s/\t/ /g;
		"$bitlate\t$artist\t$album\n";
	} sort {$a cmp $b} keys %{ $bitlates->{$artist} };
} sort {$a cmp $b} keys %$bitlates;

