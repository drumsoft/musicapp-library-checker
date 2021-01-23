#!/usr/bin/perl

use strict;
use warnings;

use utf8;
binmode STDOUT, ":utf8";

use Lingua::JA::Regular::Unicode qw/hiragana2katakana katakana_h2z space_z2h alnum_z2h/;

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
				$artist = '<Compilation>';
			} else {
				$artist = $track->get('Artist');
			}
		}
		my $album   = $track->get('Album');
		my $bitlate = $track->get('Bit Rate');
		if (($album || $artist) && $bitlate) {
			$artist = normalize($artist);
			$album = normalize($album);
			$bitlates->{$artist} = {} if ! exists $bitlates->{$artist};
			$bitlates->{$artist}->{$album} = {} if ! exists $bitlates->{$artist}->{$album};
			$bitlates->{$artist}->{$album}->{$bitlate} = 0 if ! exists $bitlates->{$artist}->{$album}->{$bitlate};
			$bitlates->{$artist}->{$album}->{$bitlate}++;
		}
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
		my $number = 0;
		# 混在している かつ 最小ビットレートが 320以下 のアルバムを表示
		my @bitlates = sort {$b <=> $a} keys %{ $bitlates->{$artist}->{$album} };
		if ( @bitlates > 1 && $bitlates[-1] < 320 ) {
			my $bitlate = join '+',  @bitlates;
			$number += $_ foreach values %{ $bitlates->{$artist}->{$album} };
			"$bitlate\t$artist\t$album\t$number\n";
		}
	} sort {$a cmp $b} keys %{ $bitlates->{$artist} };
} sort {$a cmp $b} keys %$bitlates;

sub normalize {
	my $text = shift;
	$text =~ s/[_\W]//g if $text =~ /[^_\W]/;
	$text = hiragana2katakana katakana_h2z space_z2h lc alnum_z2h $text;
	return $text;
}
