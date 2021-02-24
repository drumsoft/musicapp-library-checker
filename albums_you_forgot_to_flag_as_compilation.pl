#!/usr/bin/env perl

use strict;
use warnings;

use utf8;
binmode STDOUT, ":utf8";

use lib '.';
use XMLiTunes;

my $albums = {}; # $albums->{album}->{artist} = 1;

if ( ! $ARGV[0] ) {
	print STDERR "usage: " . __FILE__ . " iTunes_Library_Exported.xml\n";
	exit(0);
}

my $xmlitunes = XMLiTunes->new();
$xmlitunes->parse_file($ARGV[0]);

$xmlitunes->tracks(sub{
	my $track = shift;
	if (!$track->has('Compilation') && $track->get('Album')) {
		my $artist = $track->has('Album Artist') ? $track->get('Album Artist') : $track->get('Artist');
		my $album  = $track->get('Album');
		$albums->{$album} = {} if ! exists $albums->{$album};
		$albums->{$album}->{$artist} = 1;
	}
});

print join '', map {
	sprintf "%d	%s	%s\n", $_->{count}, $_->{album}, join ' / ', @{ $_->{artists} };
} sort {
	$b->{count} != $a->{count} ? $b->{count} <=> $a->{count} : $b->{album} cmp $a->{album};
} grep {
	$_;
} map {
	my @artists = keys %{ $albums->{$_} };
	@artists > 1 ?
		{ album => $_, count => scalar(@artists), artists => \@artists } :
		undef;
} keys %$albums;
