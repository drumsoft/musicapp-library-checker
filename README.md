# musicapp-library-checker

iTunes > ファイル > ライブラリ > ライブラリを書き出し で出力したxmlファイルを処理する。

## install

sudo cpanm --installdeps .

XML::LibXML がすんなりインストールできなかった。

https://www.perlmonks.org/?node_id=11124667

brew install gcc
brew install libxml2
sudo cpanm XML::LibXML # 失敗
Makefile を書き換えて make, make test, make install

## scripts

dump-library.pl ライブラリ.xml
	ライブラリをCSV形式にダンプする

check-files.pl ライブラリ.xml メディアディレクトリ ..
	ライブラリとファイルシステムの不整合を検出する

mixed_bitrate_albums_from_iTunes_xml.pl ライブラリ.xml
	ビットレート混在アルバムの一覧を出力

list_album_bitlates_from_iTunes_xml.pl ライブラリ.xml
	アルバム単位でビットレートの一覧を出力

## files

XMLiTunes.pm
	ライブラリ xml ファイルをスキャンするライブラリ
