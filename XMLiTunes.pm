package XMLiTunes;

use strict;
use warnings;
use utf8;

use XML::LibXML;

sub new {
	my $class = shift;
	return bless {
		parser => XML::LibXML->new(@_)
	}, $class;
}

sub parse_file {
	my $self = shift;
	$self->{dom} = $self->{parser}->parse_file(@_);
	return $self;
}

# <key>Tracks<key> = '/plist/dict/key[text()="Tracks"]'
# その次のdict要素(Track id をキーとする Track の一覧) = '/plist/dict/key[text()="Tracks"]/following-sibling::*[1]'
# [※1]その中のdict要素(Track の一覧) = '/plist/dict/key[text()="Tracks"]/following-sibling::*[1]/dict'
# <key>Playlist<key> = '/plist/dict/key[text()="Playlist"]'
#   部分的にテストする場合は 末尾の dict を dict[100]/preceding-sibling::dict にする。

# ライブラリからトラックリスト(※1)を取得して…
#  ->tracks() : トラックリストの nodeList を返す (XML::LibXML::NodeList)
#  ->tracks(funLoop[, funStart]) : 各トラック について funLoop を実行, funStart はループ前に一度実行される
#    funLoop( XMLiTunes::Track track ), funLoop( int count_of_track, XML::LibXML::NodeList list )
sub tracks {
	my $self = shift;
	my $funLoop  = shift;
	my $funStart = shift;
	
	if ( ! exists $self->{tracks} ) {
		$self->{tracks} = $self->{dom}->findnodes('/plist/dict/key[text()="Tracks"]/following-sibling::*[1]/dict');
	}
	
	if ( ! $funLoop ) {
		return $self->{tracks};
	}
	
	if ( $funStart ) {
		$funStart->($self->{tracks}->size(), $self->{tracks});
	}
	
	$self->{tracks}->foreach(sub {
		$funLoop->( XMLiTunes::Track->new($_) );
	});
	return $self;
}

# XML::LibXML を XMLiTunes::Track に変換
sub toTrack {
	my ($self, $node) = @_;
	return XMLiTunes::Track->new($node);
}


package XMLiTunes::Track;

sub new {
	my ($class, $node) = @_;
	return bless {
		node => $node
	}, $class;
}

# Track のテキスト情報を取得
# track->has('Album Artist')
sub get {
	my ($self, $keyname) = @_;
	my @n = $self->{node}->findnodes('key[text()="' . $keyname . '"]/following-sibling::*[1]');
	if ( @n ) {
		return $n[0]->textContent();
	}
	return '';
}

# Track のノードの有無を答える
# track->has('Compilation')
sub has {
	my ($self, $keyname) = @_;
	return $self->{node}->findnodes('key[text()="' . $keyname . '"]')->size() > 0;
}

1;
