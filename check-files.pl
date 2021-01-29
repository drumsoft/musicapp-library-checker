#!/usr/bin/env perl

use strict;
use warnings;

use utf8;
binmode STDOUT, ":utf8";
binmode STDERR, ":utf8";

use Encode;
# use 'utf-8-mac' ?
use Encode::UTF8Mac;
use File::Find;
use URI::Escape;

use lib '.';
use XMLiTunes;

my %kinds = (
'AAC オーディオファイル' => 'AAC',
'AACオーディオファイル' => 'AAC',
'AIFF オーディオファイル' => 'AIFF',
'AIFFオーディオファイル' => 'AIFF',
'Apple Losslessオーディオファイル' => 'AL',
'Apple Music AACオーディオファイル' => 'AAC',
'Apple ロスレス・オーディオファイル' => 'AL',
'MPEG audio file' => 'MP3',
'MPEG オーディオファイル' => 'MP3',
'MPEGオーディオファイル' => 'MP3',
'QuickTime ムービーファイル' => 'QT',
'WAV オーディオファイル' => 'WAV',
'WAVオーディオファイル' => 'WAV',
'マッチしたAACオーディオファイル' => 'AAC',
'保護された AAC オーディオファイル' => 'AAC',
'購入した AAC オーディオファイル' => 'AAC',
'購入したAACオーディオファイル' => 'AAC',
'MPEG-4オーディオファイル' => 'AL',
);

main(@ARGV);

sub main {
	my $xmlfile = shift;
	my @musicfolder = @_;

	my %files_found; # 実在するファイルのエントリ
	my %pathes_count; # パスの重複チェック用
	my %track_aggregation; # トラックの重複チェック結果

	# 引数
	if ( !$xmlfile || !@musicfolder ) {
		print STDERR "usage: " . __FILE__ . " iTunes_Library_Exported.xml Media_Folder_Path1 Media_Folder_Path2 ... \n";
		exit(0);
	}
	if ( ! -e $xmlfile || ! -f $xmlfile ) {
		print STDERR "$xmlfile is not a file.\n";
		exit(0);
	}
	foreach (@musicfolder) {
		if ( ! -e $_ || ! -d $_ ) {
			print STDERR "$_ is not a directory.\n";
			exit(0);
		}
	}

	# ファイル一覧を取得
	my $file = 0;
	my $directory = 0;
	my $hidden = 0;
	print STDERR "Scanning music folder: " . join(' ', @musicfolder) . "...\n";
	find(sub{
		my $path = decode 'utf-8-mac', $File::Find::name;
		my $encoded_path = encode 'utf-8-mac', $path;
		if (! -e $encoded_path) {
			print STDERR "found but not exist: $path\n";
		} elsif (-d $encoded_path) {
			$directory++;
		} elsif (! -f $encoded_path) {
			print STDERR "unknown type: $path\n";
		} elsif ($path =~ /\/\.[^\/]*$/) {
			$hidden++;
		} else {
			$file++;
			$files_found{lc $path} = $path;
		}
	}, @musicfolder);
	printf STDERR "%d files, %d folders, %d hidden files found.\n", $file, $directory, $hidden;

	# xml ファイルを読み込み
	print STDERR "Parsing library xml file: $xmlfile ...\n";
	my $xmlitunes = XMLiTunes->new();
	$xmlitunes->parse_file($xmlfile);
	
	print STDERR "Checking entry and files ...\n";
	$xmlitunes->tracks( sub{
		my $track = shift;
		my $track_name = join "\t", $track->get('Artist'), $track->get('Album'), $track->get('Name'), $track->get('Disc Number'), $track->get('Track Number'), normalize_kind($track);
		if (!exists $track_aggregation{$track_name}) {
			$track_aggregation{$track_name} = [$track];
		} else {
			push @{$track_aggregation{$track_name}}, $track;
		}
		if (!$track->has('Track Type')) {
			error($track, '"Track Type" カラムがありません');
			return;
		}
		if ($track->get('Track Type') eq 'Remote') {
			return; # Remote type, skip check.
		}
		if (!$track->has('Location')) {
			# パスが長い場合に出力xmlのみこの状態になる場合がある（元データは健全）
			error($track, '"Location" カラムがありません');
			return;
		}
		my $location = $track->get('Location');
		if ( ($location =~ s{^file://}{}) == 0 ) {
			error($track, 'パスがファイルプロトコルではありません: ' . $location);
			return;
		}
		$location = decode 'utf-8-mac', uri_unescape($location);
		if (! -e encode 'utf-8-mac', $location) {
			error($track, 'ファイルが存在しないトラックです: ' . $location);
			return;
		}
		if (exists $pathes_count{lc $location}) {
			error($track, 'このパスを参照するトラックが複数あります: ' . $location);
			return;
		}
		$pathes_count{lc $location} = 1;
		if (! exists $files_found{lc $location}) {
			error($track, 'このファイルは存在しますが、事前スキャンで未発見です: ' . $location);
			return;
		}
		delete $files_found{lc $location};
	});
	
	print "\n== ファイルシステムに存在する、ライブラリに含まれないファイル一覧 ==\n";
	print join "\n", sort values %files_found;
	
	print "\n== 重複の可能性があるトラック一覧 ==\n";
	print join "\n", map {
		my $tracks = $track_aggregation{$_};
		scalar(@$tracks) . "\t" . $_;
	} sort grep { @{$track_aggregation{$_}} > 1 } keys %track_aggregation;
	
	print "\n\n";
}


sub normalize_kind {
	my $track = shift;
	if ($track->has('Kind')) {
		my $k = $track->get('Kind');
		if (exists $kinds{$k}) {
			return $kinds{$k};
		}
		error($track, '未知の Kind です: ' . $k);
	}
	return '';
}

sub error {
	my $track = shift;
	my $message = shift;
	printf "ERROR %s, %s, %s: %s\n", $track->get('Artist'), $track->get('Album'), $track->get('Name'), $message;
}
