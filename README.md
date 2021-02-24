# musicapp-library-checker

Analyze the Music (iTunes) library to find problems. 

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

## ライブラリのチェック

ライブラリとファイルシステム中のファイルの不整合を検出する

```
./check-files.pl ライブラリ.xml メディアディレクトリ ..
```

メディアディレクトリは複数指定できる。

## その他のスクリプト

```
ライブラリをCSV形式にダンプする
./dump-library.pl ライブラリ.xml

「コンピレーション」フラグか、アルバムアーティストの設定が忘れられているかもしれないアルバムの一覧
./albums_you_forgot_to_flag_as_compilation.pl ライブラリ.xml

ビットレートが混在しているアルバムの一覧を出力
./mixed_bitrate_albums_from_iTunes_xml.pl ライブラリ.xml
	表記揺れの正規化を行うために別途 Lingua::JA::Regular::Unicode が必要

アルバム単位でビットレートの一覧を出力
./list_album_bitlates_from_iTunes_xml.pl ライブラリ.xml
```

## files

XMLiTunes.pm
	ライブラリ xml ファイルをスキャンするライブラリ
