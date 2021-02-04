# musicapp-library-checker

Music (iTunes) のライブラリを解析して問題のある箇所を見つけたりしたい。

ファイル > ライブラリ > ライブラリを書き出し... で出力したxmlファイルを読み込んで色々やる。

## install

sudo cpanm --installdeps .

### [Big Sur] XML::LibXML がすんなりインストールできなかった。

https://www.perlmonks.org/?node_id=11124667

```
brew install gcc
brew install libxml2
sudo cpanm XML::LibXML # 失敗
# cpanm のビルドディレクトリに移動 Makefile を上記記事を参考に書き換えて
sudo make
sudo make test
sudo make install
```

## scripts

```
./check-files.pl ライブラリ.xml メディアディレクトリ ..
	ライブラリとファイルシステム中のファイルの不整合を検出する

./dump-library.pl ライブラリ.xml
	ライブラリをCSV形式にダンプする

./mixed_bitrate_albums_from_iTunes_xml.pl ライブラリ.xml
	ビットレート混在アルバムの一覧を出力
	表記揺れの正規化を行うために別途 Lingua::JA::Regular::Unicode が必要

./list_album_bitlates_from_iTunes_xml.pl ライブラリ.xml
	アルバム単位でビットレートの一覧を出力
```

## files

XMLiTunes.pm
	ライブラリ xml ファイルをスキャンするライブラリ
