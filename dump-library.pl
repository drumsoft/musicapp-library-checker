#!/usr/bin/env perl

use strict;
use warnings;

use utf8;
binmode STDOUT, ":utf8";

use lib '.';
use XMLiTunes;

my @columns = (
	"Track ID",
	"Name", "Artist", "Composer", "Album",
	"Genre", "Kind",
	"Size", "Total Time",
	"Disc Number", "Disc Count", "Track Number", "Track Count",
	"Year", "Date Modified", "Date Added",
	"Bit Rate", "Sample Rate",
	"Play Count", "Play Date", "Play Date UTC",
	"Normalization", "Persistent ID",
	"Track Type",
	"Location", "File Folder Count", "Library Folder Count"
);

if ( ! $ARGV[0] ) {
	print STDERR "usage: " . __FILE__ . " iTunes_Library_Exported.xml\n";
	exit(0);
}

my $xmlitunes = XMLiTunes->new();
$xmlitunes->parse_file($ARGV[0]);

print join("\t", @columns), "\n";

sub quote {
	my $a = shift;
	if ($a =~ /[\t\n\r\"]/) {
		$a =~ s/\"/\"\"/g;
		$a = "\"$a\"";
	}
	return $a;
}

$xmlitunes->tracks( sub{
	my $track = shift;
	print join("\t", map {
		$track->has($_) ? quote($track->get($_)) : ''
	} @columns), "\n";
});
