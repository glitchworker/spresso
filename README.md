# sPresso StarterKit
**sPresso StarterKit for modern websites**

gulp / ect / sass / webpack (coffeescript)

## Usage

1. [NodeJS](https://nodejs.org/en/) をダウンロードしインストールする

2. ターミナルまたはコマンドプロンプトを管理者権限で開く

3. ```npm install -g yarnpkg``` で Yarn をインストールする

4. ```yarn global add gulp``` で Gulp をインストールする（npm の場合 ```npm install -g gulp```）

5. ```yarn install``` で必要なパッケージをインストール（出来ない場合 ```sudo yarn install```）

6. ```/src/app.config.json``` を開き各項目を編集しておく（後から変更可能）

7. ```yarn run dev``` で一度ビルドしておく

8. ```yarn run start``` で開発環境を起動する（自動的に既存のブラウザが起動）

9. 後は ```/src/``` フォルダ内のファイルを編集し作業をする

10. 以降8〜9の繰り返し

本番環境にアップロードする場合、```yarn run prod``` を実行し ```/htdocs/``` 内をアップする
※ 各設定ファイルについては Setting 、開発用のコマンドについては Scripts を参照

また、7 の時に ```yarn run diff``` としておくと ```/htdocs/``` と ```/temp/``` フォルダが生成され
作業後に ```yarn run export``` を実行すると差分データが ```/archive/``` フォルダに zip 形式で出力される
※作業を開始する前に実行しておくと作業開始時から編集後の差分データを出力することが出来る
　つまり実行しなければ過去に実行した時点からの差分を出力することが可能

**v1.1.0 から新たに src フォルダに import フォルダが追加されました。**
この中にファイル又はフォルダを追加し data.json に設定を記述することによって
本テンプレート以外にユーザーが自由に設定したファイル＆フォルダを htdocs に出力することが可能です。
フォルダの場合は type に dir ファイルの場合は file を記述し data にフォルダ名またはファイル名を入力した後
output の項目に出力先のパスを入力することによって書き出されます。

## Setting

### project

| ファイル名 | 説明 |
|----|---|
| /src/app.config.json | プロジェクト内共通の設定ファイル ※ネストは非対応 |
| /tasks/gulp.config.coffee | gulp に関する設定ファイル |
| /tasks/webpack.config.base.coffee | webpack に関する設定ファイル |
| /tasks/webpack.config.common.coffee | 共通の webpack に関する設定ファイル |
| /tasks/webpack.config.pc.coffee | webpack に関する設定ファイル（PC） |
| /tasks/webpack.config.sp.coffee | webpack に関する設定ファイル（SP） |

### src

| ファイル名 | 説明 |
|----|---|
| /src/pc/template/pages.json | template 内で使う規定値（PC） |
| /src/sp/template/pages.json | template 内で使う規定値（SP） |
| /src/common/stylesheets/_config.scss | stylesheet 内で使う規定値 |
| /src/import/data.json | import で使う規定値 |

## 規定値をsrc内で共有する方法

共通の規定値は app.config.json に定義してください。
規定値の参照方法は以下

#### ectの場合

| 記述 | 説明 |
|----|---|
| <%- @path %> | ディレクトリパス |
| <%- @path_filename %> | ファイルパス |
| <%- @SITE_URL %> | サイトURL |
| <%- @SITE_NAME %> | サイト名 |

/src/(pc か sp)/templates/pages.json 内で json を取得しています。 ```<%- @meta_title %>``` 等で参照できます。
上記以外にも、pages.json に記入された内容は呼び出すことが可能です。
```<% for head in @head : %><% end %>``` で囲むことによって meta 情報の入れ子を以下の様に
記述することによって取得可能にしています。

| 記述 | 説明 |
|----|---|
| <%- head.meta_title %> | ページ名 |
| <%- head.meta_keywords %> | ページキーワード |
| <%- head.meta_description %> | ページデスクリプション |
| <%- head.meta_author %> | ページ製作者 |
| <%- head.meta_appleIcon %> | iPhone用アイコン |
| <%- head.meta_icon %> | モダン用アイコン |
| <%- head.meta_iconXhtml %> | 旧IE用アイコン |
| <%- head.meta_facebook %> | facebookのmetaタグ |
| <%- head.meta_twitter %> | twitterのmetaタグ |
| <%- head.meta_windows %> | windowsのmetaタグ |

#### sassの場合

| 記述 | 説明 |
|----|---|
| #{$SITE_URL} | サイトURL |
| #{$SITE_NAME} | サイト名 |
| #{$AUTHOR} | サイト制作者 |
| #{$MODIFIER} | サイト編集者 |
| #{$UPDATE} | ファイル更新日時 |
| #{$TIMESTAMP} | ファイル更新日時Unix |

/src/common/stylesheets/_config.scss 内で json を取得しています。 ```#{$SITE_NAME}``` 等で参照できます。
また sass の map 形式に変換されるので、 ```map-get($appConfig, [hash])``` 等で参照できます。

#### coffeescriptの場合

| 記述 | 説明 |
|----|---|
| APP_SITE_URL | サイトURL |
| APP_SITE_NAME | サイト名 |
| APP_AUTHOR | サイト制作者 |
| APP_MODIFIER | サイト編集者 |
| APP_UPDATE | ファイル更新日時 |
| APP_TIMESTAMP | ファイル更新日時Unix |

webpack に DefinePlugin として渡しているので、 ```APP_SITE_URL``` 等で参照できます。

## Scripts

### watch

#### 監視タスク実行

| Yarn コマンド | Gulp コマンド | 説明 |
|----|---|---|
| yarn run start | gulp | 開発サーバーを起動する |
| yarn run start-prod | gulp --env production | 開発サーバーを本番状態で起動する |
| yarn run start-pc | gulp watch-pc | 開発サーバーを起動する（PC） |
| yarn run start-sp | gulp watch-sp | 開発サーバーを起動する（SP） |

### build

#### ビルド出力

| Yarn コマンド | Gulp コマンド | 説明 |
|----|---|---|
| yarn run dev | gulp build | 開発用のファイルを出力 |
| yarn run dev-pc | gulp build-pc | 開発用のファイルを出力（PC） |
| yarn run dev-sp | gulp build-sp | 開発用のファイルを出力（SP） |
| yarn run prod | gulp build --env production | 本番用のファイルを出力 |
| yarn run prod-pc | gulp build-pc --env production | 本番用のファイルを出力（PC） |
| yarn run prod-sp | gulp build-sp --env production | 本番用のファイルを出力（SP） |

### diff / export

#### 一時ファイル＆差分データ出力

| Yarn コマンド | Gulp コマンド | 説明 |
|----|---|---|
| yarn run diff | gulp diff | 開発用一時データを出力 |
| yarn run diff-prod | gulp diff --env production | 本番用一時データを出力 |
| yarn run export | gulp export | 差分データを出力 |

### others / clean

#### インポートデータのタスク実行

| Yarn コマンド | Gulp コマンド | 説明 |
|----|---|---|
| yarn run import | gulp import | 追加データの出力 |

#### ディレクトリ削除

| Yarn コマンド | Gulp コマンド | 説明 |
|----|---|---|
| yarn run clean | gulp clean | ビルドフォルダを削除 |
| yarn run clean-diff | gulp clean-archive | 差分フォルダを削除 |

## Structure

### outline

	./
	├── LICENSE
	├── README.md
	├── gulpfile.coffee
	├── package.json
	├── src
	│   ├── app.config.json
	│   ├── import
	│   │   └── data.json
	│   ├── common
	│   │   ├── images
	│   │   │   ├── favicon.ico
	│   │   │   ├── favicon.png
	│   │   │   ├── ogp_image.jpg
	│   │   │   └── tile_image.png
	│   │   ├── scripts
	│   │   │   ├── coffee
	│   │   │   │   ├── common.coffee
	│   │   │   │   ├── index.coffee
	│   │   │   │   └── modules
	│   │   │   │       └── Selector.coffee
	│   │   │   ├── javascript
	│   │   │   │   └── javascript.js
	│   │   │   ├── lib
	│   │   │   │   ├── html5shiv.min.js
	│   │   │   │   ├── jquery-1.10.2.min.js
	│   │   │   │   ├── jquery-2.2.4.min.js
	│   │   │   │   └── selectivizr.min.js
	│   │   │   └── plugin
	│   │   │       └── plugin.js
	│   │   └── stylesheets
	│   │       ├── _config.scss
	│   │       ├── _reset.scss
	│   │       ├── mixins
	│   │       │   ├── _clearfix.scss
	│   │       │   ├── _fontSize.scss
	│   │       │   ├── _hideaway.scss
	│   │       │   ├── _inlineBlock.scss
	│   │       │   ├── _mediaqueries.scss
	│   │       │   └── _opacity.scss
	│   │       ├── utils
	│   │       │   ├── _align.scss
	│   │       │   ├── _display.scss
	│   │       │   ├── _float.scss
	│   │       │   ├── _font.scss
	│   │       │   ├── _margin.scss
	│   │       │   ├── _padding.scss
	│   │       │   ├── _visibility.scss
	│   │       │   └── _width.scss
	│   │       └── vars
	│   │           ├── _color.scss
	│   │           └── _easing.scss
	│   ├── pc
	│   │   ├── images
	│   │   │   ├── index
	│   │   │   │   └── image.png
	│   │   │   ├── hoge
	│   │   │   │   └── image.png
	│   │   │   ├── fuga
	│   │   │   │   └── image.png
	│   │   │   └── image.png
	│   │   ├── scripts
	│   │   │   ├── coffee
	│   │   │   │   ├── fuga.coffee
	│   │   │   │   ├── hoge.coffee
	│   │   │   │   ├── index.coffee
	│   │   │   │   └── modules
	│   │   │   ├── javascript
	│   │   │   │   └── javascript.js
	│   │   │   └── plugin
	│   │   │       └── plugin.js
	│   │   ├── stylesheets
	│   │   │   ├── _fuga.scss
	│   │   │   ├── _hoge.scss
	│   │   │   ├── _index.scss
	│   │   │   ├── app.scss
	│   │   │   ├── partials
	│   │   │   │   ├── _content.scss
	│   │   │   │   ├── _footer.scss
	│   │   │   │   └── _header.scss
	│   │   │   └── bases
	│   │   │       ├── _config.scss
	│   │   │       └── _default.scss
	│   │   └── templates
	│   │       ├── bases
	│   │       │   ├── _head.ect
	│   │       │   └── _layout.ect
	│   │       ├── partials
	│   │       │   ├── _footer.ect
	│   │       │   └── _header.ect
	│   │       ├── fuga.ect
	│   │       ├── hoge.ect
	│   │       ├── index.ect
	│   │       └── pages.json
	│   └── sp
	│       ├── images
	│       │   ├── index
	│       │   │   └── image.png
	│       │   ├── hoge
	│       │   │   └── image.png
	│       │   ├── fuga
	│       │   │   └── image.png
	│       │   └── image.png
	│       ├── scripts
	│       │   ├── coffee
	│       │   │   ├── fuga.coffee
	│       │   │   ├── hoge.coffee
	│       │   │   ├── index.coffee
	│       │   │   └── modules
	│       │   ├── javascript
	│       │   │   └── javascript.js
	│       │   └── plugin
	│       │       └── plugin.js
	│       ├── stylesheets
	│       │   ├── _fuga.scss
	│       │   ├── _hoge.scss
	│       │   ├── _index.scss
	│       │   ├── app.scss
	│       │   ├── partials
	│       │   │   ├── _content.scss
	│       │   │   ├── _footer.scss
	│       │   │   └── _header.scss
	│       │   └── bases
	│       │       ├── _config.scss
	│       │       └── _default.scss
	│       └── templates
	│           ├── bases
	│           │   ├── _head.ect
	│           │   └── _layout.ect
	│           ├── partials
	│           │   ├── _footer.ect
	│           │   └── _header.ect
	│           ├── fuga.ect
	│           ├── hoge.ect
	│           ├── index.ect
	│           └── pages.json
	└── tasks
		├── gulp.config.coffee
		├── script
		│   ├── getTime.coffee
		│   ├── getTimeStamp.coffee
		│   └── sassGetJson.coffee
		├── webpack.config.base.coffee
		├── webpack.config.pc.coffee
		├── webpack.config.sp.coffee
		└── webpack.config.common.coffee

### src

	./src
	├── import
	├── common
	│   ├── images
	│   ├── scripts
	│   │   ├── coffee
	│   │   │   └── modules
	│   │   ├── javascript
	│   │   ├── lib
	│   │   └── plugin
	│   └── stylesheets
	│       ├── mixins
	│       ├── utils
	│       └── vars
	├── pc
	│   ├── images
	│   ├── scripts
	│   │   ├── coffee
	│   │   │   └── modules
	│   │   ├── javascript
	│   │   └── plugin
	│   ├── stylesheets
	│   │   ├── bases
	│   │   └── partials
	│   └── templates
	│       ├── bases
	│       └── partials
	└── sp
		├── images
		├── scripts
		│   ├── coffee
		│   │   └── modules
		│   ├── javascript
		│   └── plugin
		├── stylesheets
		│   ├── bases
		│   └── partials
		└── templates
			├── bases
			└── partials


### htdocs

	./htdocs
	├── assets
	│   ├── common
	│   │   ├── images
	│   │   └── js
	│   │       └── lib
	│   ├── pc
	│   │   ├── css
	│   │   ├── images
	│   │   └── js
	│   └── sp
	│       ├── css
	│       ├── images
	│       └── js
	└── sp


## Coding Guideline

### sass

#### Structure
	./
	├── _config.scss # 設定ファイル
	├── _reset.scss # 共通リセット
	├── app.scss # メインファイル
	├── partials # 共通部分を設置
	├── mixins # ミックスインを設置
	├── utils # 汎用クラスを設置
	└── vars # 汎用的に使える変数などを設置


## Dependencies

- [NodeJS](https://nodejs.org/en/)
- [Gulp](http://gulpjs.com/)
- [npm](https://www.npmjs.com/)
- [Yarn](https://yarnpkg.com/)

## Issues

- [GitHub Issues](https://github.com/glitchworker/spresso/issues)

## Version History

### v1.1.7

- yarn run start-prod の コマンドを追加
- gulp.config.coffee の pathArray のロジック変更（ビルド時に htdocs 内を綺麗にするように）
- gulp-sass-glob を一時的に削除（app.scss に @include を記述するスタイルに変更）
- WebPack 圧縮時にコンストラクタ名が省略されるため、constructor.name が動いていなかったのを修正
- hoge の他に fuga のサンプルディレクトリも追加
- meta タグの旧IE用コンディショナルコメントを pages.json 項目で個別に有効・無効出来るように変更
- README.md の修正

### v1.1.6

- gulp-sass-glob が Windows で正常に動いていなかったのを修正
- README.md の修正

### v1.1.5

- gulp のタスクで画像関連が機能していなかったのを修正
- LICENSE の copyright の修正

### v1.1.4

- gulp-sass-glob の追加
- sass の @import における glob を有効にする
- package.json の更新

### v1.1.3

- Selector.coffee に iPhone 機種判別処理実装
- package.json の更新

### v1.1.2

- タスク実行コマンドの大幅変更
- webpack.config.xxxx.coffee 設定の調整
- package.json の更新
- README.md の修正

### v1.1.1

- meta タグの lang 属性を指定出来るように変更
- webpack.config.xxxx.coffee 設定の最適化
- README.md の修正

### v1.1.0

- インポートデータ機能の追加
- package.json の更新
- README.md の修正

### v1.0.0

- webpack.config.base.coffee の追加（共通設定）
- 正式リリース

### v0.2.1

- webpack-merge のパッケージを追加（webpack.config ファイルの設定を共通化させるため）
- sp の viewport を変更
- addScripts を addScriptsHeader と addScriptsFooter に分け上下にタグを追加出来るように変更
- package.json の更新

### v0.2.0

- yarn run zip を yarn run export に変更
- gulp.config.coffee の整理
- pages.json に redirect の項目を追加（リダイレクトさせたくないページを個別に設定）
- package.json の更新
- README.md の修正

### v0.1.9

- 差分を書き出す際に、更新日時ではなく SHA1 で比較するように変更
- UPDATE または TIMESTAMP を含めていると差分が取れないので一旦コメントアウト
- temp フォルダを作る方法を変更（ yarn run diff ）で一時フォルダ作成

### v0.1.8

- build タスクを並列処理から直列処理に変更（pathSearch 関数の競合回避の為）
- package.json の更新
- README.md の修正

### v0.1.7

- ect のタスクがちゃんと出力されていなかったのを修正
- package.json のプラグインを名前順に変更
- Gulp のタスクを大幅に変更＆コメント記述

### v0.1.6

- html の削除部分で稀にエラーが出ていたのを修正
- pathSearch の実装方法の変更（フォルダが深くなっても反映されるように）
- Gulp タスクのロジック周りの微調整

### v0.1.5

- 差分データを zip ファイルに出力するタスク実装
- 上記に伴い、archives と temp フォルダを削除するタスク実装
- scss でエラーが出てもタスクが止まらないように変更
- scss に MediaQueries の mixin を追加
- pathSearch を実装した事によって、src と htdocs のファイルの変更＆削除の同期処理を実装
- 上記の実装を使って、本番ビルド時に sourcemaps の map ファイルを削除

### v0.1.4

- scss の サイトURLの取得を #{$SITE_URL} に統一するようにタスクを変更
- meta タグの name 属性の author を pages.json 項目未入力の場合非表示にするように変更
- meta タグの lang 属性をページ別に pages.json を変更することを可能にし、多言語ページ対応
- stylesheets と templates のディレクトリ構造を統一化
- meta タグに Google+ を追加
- body タグのページクラス名の接頭辞に page- を付けるように変更（クラス名の被り防止の為）
- package.json の更新
- README.md の修正

### v0.1.3

- pages.json の meta 情報を入れ子で取得するように変更
- BrowserSync の log 出力にプロジェクト名（サイト名）で表示するように変更
- scss を css 変更後にリロードするようにしていたのを stream に流してリアルタイムに反映するように変更
- ect を html 変更後にリロードするようにしていたのを stream に流してリアルタイムに反映するように変更
- coffee を js 変更後にリロードするようにしていたのを stream に流してリアルタイムに反映するように変更
- README.md の修正

### v0.1.2

- js を結合する際の順番を plugin javascript coffee の順番に変更（優先度の確立）
- リダイレクト処理を大幅に変更＆パラメータに対応

### v0.1.1

- sourcemaps が本番ビルド時に sass に残っていたのを修正
- uglify で圧縮するタイミングを webpack 内に移動（Gulp 側で実行すると怒られる為）
- 全ての BrowserSync のリロードタイミングをファイル出力後に変更
- WebPack で複数の coffee を扱う際、自身のコンストラクタ名を取得し該当ページで実行されるように変更
- README.md の修正

### v0.1.0

- sourcemaps のタイミングが間違っていたのを修正
- ビルド対象を拡張子で厳密に判断するように変更

### v0.0.9

- gulp.config.coffee の調整
- ect のタイムラグ対策に html ファイルが更新されたらリロードするように変更

### v0.0.8

- gulp-changed & gulp-imagemin & gulp-watch 追加
- 上記を使い src ディレクトリで一元管理するように変更
- gulp-chenged により差分比較での出力に対応（画像系＆pages.json はファイル変更後に反映）
- gulp-watch により image ディレクトリの新規追加の監視に対応
- package の整理（gulp-filesize 削除）
- pages.json の更新
- README.md の修正

### v0.0.7

- packageの整理（jQuery と underscore 削除）
- gulp-header & gulp-footer 追加
- 上記を使いストリーム中のファイル先頭にコメント挿入
- BrowserSync の設定調整

### v0.0.6

- BrowserSync のバグを修正

### v0.0.5

- package.json 修正
- Gulpタスクの処理を調整
- README.mdの修正

### v0.0.4

- package.json バージョン更新
- templates/base/_head.ect の調整
- README.md の修正

### v0.0.3

- WebPack の設定情報変更
- DefinePlugin の設定変更
- デバッグコードを削除するように uglify 設定変更
- SCSSの mixin と utils を追加

### v0.0.2

- タスクファイル分割
- 不要なファイルの整理

### v0.0.1

- 初回リリース