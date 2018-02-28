# sPresso StarterKit

[![license](https://img.shields.io/github/license/glitchworker/spresso.svg)](https://github.com/glitchworker/spresso/blob/master/LICENSE)

**sPresso StarterKit for modern websites**

gulp / ect / sass ( scss ) / webpack (coffeescript)

## Usage

1. [NodeJS](https://nodejs.org/en/) をダウンロードしインストールする

2. ターミナルまたはコマンドプロンプトを管理者権限で開く

3. ```npm install -g yarnpkg``` で Yarn をインストールする（npm のままビルドする場合は不要）

4. ```yarn global add gulp``` で Gulp をインストールする（npm の場合 ```npm install -g gulp```）

5. ```yarn install``` で必要なパッケージをインストール（npm の場合 ```npm install```）

6. ```/src/app.config.json``` を開き各項目を編集しておく（後から変更可能）

7. ```yarn run dev``` で一度ビルドしておく（npm の場合 ```npm run dev```）

8. ```yarn run start``` で開発環境を起動する（自動的に既存のブラウザが起動）（npm の場合 ```npm run start```）

9. 後は ```/src/``` フォルダ内のファイルを編集し作業をする

10. 以降8〜9の繰り返し

> 本番環境にアップロードする場合、```yarn run prod``` を実行し ```/htdocs/``` 内をアップする
※ 各設定ファイルについては Setting 、開発用のコマンドについては Scripts を参照
> 
> また、7 の時に ```yarn run diff``` としておくと ```/htdocs/``` と ```/temp/``` フォルダが生成され
作業後に ```yarn run export``` を実行すると差分データが ```/archive/``` フォルダに zip 形式で出力される
※作業を開始する前に実行しておくと作業開始時から編集後の差分データを出力することが出来る
　つまり実行しなければ過去に実行した時点からの差分を出力することが可能

## Setting

### project

| ファイル名 | 説明 |
|----|---|
| /src/app.config.json | プロジェクト内共通の設定ファイル ※ネストは非対応 |
| /tasks/gulp.config.coffee | gulp に関する設定ファイル |
| /tasks/webpack.config.base.coffee | webpack に関する設定ファイル |
| /tasks/webpack.config.common.coffee | 共通の webpack に関する設定ファイル |
| /tasks/webpack.config.rp.coffee | webpack に関する設定ファイル（Responsive） |
| /tasks/webpack.config.pc.coffee | webpack に関する設定ファイル（PC） |
| /tasks/webpack.config.sp.coffee | webpack に関する設定ファイル（SP） |

#### app.config.json

```json
{
  "DEV_SITE_URL": "http://dev.hoge.com/",
  "PROD_SITE_URL": "http://prod.hoge.com/",
  "CURRENT_DIR": "",
  "ASSETS_DIR": "assets/",
  "SITE_NAME": "これはサイト名です",
  "AUTHOR": "これは作成者です",
  "MODIFIER": "これは編集者です",
  "RESPONSIVE_TEMPLATE": false,
  "ABSOLUTE_PATH": false
}
```

### src

| ファイル名 | 説明 |
|----|---|
| /src/rp/template/pages.json | template 内で使う規定値（Responsive） |
| /src/pc/template/pages.json | template 内で使う規定値（PC） |
| /src/sp/template/pages.json | template 内で使う規定値（SP） |
| /src/common/stylesheets/_config.scss | stylesheet 内で使う規定値 |
| /src/import/data.json | import で使う規定値 |

#### pages.json

```json
[
  {
    "PATH_FILENAME": "index.html",
    "TEMPLATE_ECT": "index",
    "LANGUAGE": "ja",
    "NAMESPACE": "website",
    "REDIRECT": true,
    "HEAD": [
      {
        "META_CHARSET": "UTF-8",
        "META_TITLE": "これはタイトルです",
        "META_ROBOTS": "index,follow",
        "META_KEYWORDS": "これはキーワードです",
        "META_DESCRIPTION": "これはディスクリプションです",
        "META_AUTHOR": "",
        "META_COPYRIGHT": "",
        "META_VIEWPORT": "width=1280",
        "META_APPLE_ICON": "favicon.png",
        "META_ICON": "favicon.png",
        "META_XHTML_ICON": "favicon.ico",
        "META_FACEBOOK": true,
        "META_FACEBOOK_ID": "",
        "META_FACEBOOK_IMAGE": "ogp_image.jpg",
        "META_TWITTER": false,
        "META_TWITTER_CARD": "summary_large_image",
        "META_TWITTER_ACCOUNT": "",
        "META_TWITTER_APP_ANDROID": "",
        "META_TWITTER_APP_IPAD": "",
        "META_TWITTER_APP_IPHONE": "",
        "META_GOOGLE": false,
        "META_WINDOWS": false,
        "META_WINDOWS_IMAGE": "tile_image.png",
        "META_WINDOWS_COLOR": "#000000",
        "META_OLD_BROWSER": false
      }
    ]
  }
]
```

#### data.json

```json
[
  {
    "TYPE": "dir",
    "DATA": "フォルダ名",
    "OUTPUT": "出力先のパス"
  },
  {
    "TYPE": "file",
    "DATA": "ファイル名",
    "OUTPUT": "出力先のパス"
  }
]
```

## 規定値をsrc内で共有する方法

共通の規定値は app.config.json に定義してください。
規定値の参照方法などは以下をご覧ください。

#### ectの場合

| 記述 | 説明 |
|----|---|
| <%- @RELATIVE_PATH %> | ディレクトリ相対パス |
| <%- @CURRENT_DIR %> | カレントディレクトリ |
| <%- @ASSETS_DIR %> | アセットディレクトリ |
| <%- @PATH_FILENAME %> | ファイルパス |
| <%- @BASE_SITE_URL %> | サイトURL |
| <%- @SITE_URL %> | サイトURL（カレントディレクトリを含む） |
| <%- @SITE_NAME %> | サイト名 |

> /src/(rp か pc か sp)/templates/pages.json 内で json を取得しています。 ```<%- @HEAD.META_TITLE %>``` 等で参照できます。
上記以外にも、pages.json に記入された内容は呼び出すことが可能です。
```<% for HEAD in @HEAD : %><% end %>``` で囲むことによって meta 情報の入れ子を以下の様に
記述することによって取得可能にしています。

| 記述 | 説明 |
|----|---|
| <%- HEAD.META_TITLE %> | ページ名 |
| <%- HEAD.META_KEYWORDS %> | ページキーワード |
| <%- HEAD.META_DESCRIPTION %> | ページデスクリプション |
| <%- HEAD.META_AUTHOR %> | ページ製作者 |
| <%- HEAD.META_APPLE_ICON %> | iPhone用アイコン |
| <%- HEAD.META_ICON %> | モダン用アイコン |
| <%- HEAD.META_XHTML_ICON %> | 旧IE用アイコン |
| <%- HEAD.META_FACEBOOK %> | facebookのmetaタグ |
| <%- HEAD.META_TWITTER %> | twitterのmetaタグ |
| <%- HEAD.META_WINDOWS %> | windowsのmetaタグ |

#### sassの場合

| 記述 | 説明 |
|----|---|
| #{$BASE_SITE_URL} | サイトURL |
| #{$SITE_URL} | サイトURL（カレントディレクトリを含む） |
| #{$SITE_NAME} | サイト名 |
| #{$AUTHOR} | サイト制作者 |
| #{$MODIFIER} | サイト編集者 |
| #{$UPDATE} | ファイル更新日時 |
| #{$TIMESTAMP} | ファイル更新日時Unix |

> /src/common/stylesheets/_config.scss 内で json を取得しています。 ```#{$SITE_NAME}``` 等で参照できます。
また sass の map 形式に変換されるので、 ```map-get($appConfig, [hash])``` 等で参照できます。

<u>**v1.3.2 から Gulp のタスク内に参照先を変更しました。**</u>

> 今まで sass の function 機能を使い、独自モジュールを使って取得していましたが
sass に依存してしまうので gulp-header を使い Gulp タスク内で完結するようにしました。
それに伴い、/src/common/stylesheets/_config.scss 内の変数宣言を削除しました。

#### coffeescriptの場合

| 記述 | 説明 |
|----|---|
| APP_BASE_SITE_URL | サイトURL |
| APP_SITE_URL | サイトURL（カレントディレクトリを含む） |
| APP_SITE_NAME | サイト名 |
| APP_AUTHOR | サイト制作者 |
| APP_MODIFIER | サイト編集者 |
| APP_UPDATE | ファイル更新日時 |
| APP_TIMESTAMP | ファイル更新日時Unix |

> webpack に DefinePlugin として渡しているので、 ```APP_SITE_URL``` 等で参照できます。

## Scripts

### watch

#### 監視タスク実行

| Yarn コマンド | Gulp コマンド | 説明 |
|----|---|---|
| yarn run start | gulp | 開発サーバーを起動する |
| yarn run start-prod | gulp --env production | 開発サーバーを本番状態で起動する |
| yarn run start-rp | gulp watch-rp | 開発サーバーを起動する（Responsive） |
| yarn run start-pc | gulp watch-pc | 開発サーバーを起動する（PC） |
| yarn run start-sp | gulp watch-sp | 開発サーバーを起動する（SP） |

### build

#### ビルド出力

| Yarn コマンド | Gulp コマンド | 説明 |
|----|---|---|
| yarn run dev | gulp build | 開発用のファイルを出力 |
| yarn run dev-rp | gulp build-rp | 開発用のファイルを出力（Responsive） |
| yarn run dev-pc | gulp build-pc | 開発用のファイルを出力（PC） |
| yarn run dev-sp | gulp build-sp | 開発用のファイルを出力（SP） |
| yarn run prod | gulp build --env production | 本番用のファイルを出力 |
| yarn run prod-rp | gulp build-rp --env production | 本番用のファイルを出力（Responsive） |
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
	│   ├── postcss-sorting.json
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
	│   │   │   │   ├── jquery-1.12.4.min.js
	│   │   │   │   ├── jquery-3.3.1.min.js
	│   │   │   │   └── selectivizr.min.js
	│   │   │   └── plugin
	│   │   │       └── plugin.js
	│   │   └── stylesheets
	│   │       ├── _config.scss
	│   │       ├── _reset.scss
	│   │       ├── mixins
	│   │       │   ├── _clearfix.scss
	│   │       │   ├── _css3fix.scss
	│   │       │   ├── _fontSize.scss
	│   │       │   ├── _hideaway.scss
	│   │       │   ├── _inlineBlock.scss
	│   │       │   ├── _inlinefix.scss
	│   │       │   ├── _mediaqueries.scss
	│   │       │   └── _opacity.scss
	│   │       ├── utils
	│   │       │   ├── _align.scss
	│   │       │   ├── _display.scss
	│   │       │   ├── _float.scss
	│   │       │   ├── _font.scss
	│   │       │   ├── _margin.scss
	│   │       │   ├── _padding.scss
	│   │       │   ├── _tooltips.scss
	│   │       │   ├── _visibility.scss
	│   │       │   └── _width.scss
	│   │       └── vars
	│   │           ├── _color.scss
	│   │           └── _easing.scss
	│   ├── rp
	│   │   ├── images
	│   │   │   ├── index
	│   │   │   │   └── image.png
	│   │   │   ├── hoge
	│   │   │   │   ├── image.png
	│   │   │   │   └── fuga
	│   │   │   │       └── image.png
	│   │   │   └── image.png
	│   │   ├── scripts
	│   │   │   ├── coffee
	│   │   │   │   ├── common.coffee
	│   │   │   │   ├── hoge.coffee
	│   │   │   │   ├── index.coffee
	│   │   │   │   └── modules
	│   │   │   ├── javascript
	│   │   │   │   └── javascript.js
	│   │   │   └── plugin
	│   │   │       └── plugin.js
	│   │   ├── stylesheets
	│   │   │   ├── _hoge_fuga.scss
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
	│   │       ├── hoge_fuga.ect
	│   │       ├── hoge.ect
	│   │       ├── index.ect
	│   │       └── pages.json
	│   ├── pc
	│   │   ├── images
	│   │   │   ├── index
	│   │   │   │   └── image.png
	│   │   │   ├── hoge
	│   │   │   │   ├── image.png
	│   │   │   │   └── fuga
	│   │   │   │       └── image.png
	│   │   │   └── image.png
	│   │   ├── scripts
	│   │   │   ├── coffee
	│   │   │   │   ├── common.coffee
	│   │   │   │   ├── hoge.coffee
	│   │   │   │   ├── index.coffee
	│   │   │   │   └── modules
	│   │   │   ├── javascript
	│   │   │   │   └── javascript.js
	│   │   │   └── plugin
	│   │   │       └── plugin.js
	│   │   ├── stylesheets
	│   │   │   ├── _hoge_fuga.scss
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
	│   │       ├── hoge_fuga.ect
	│   │       ├── hoge.ect
	│   │       ├── index.ect
	│   │       └── pages.json
	│   └── sp
	│       ├── images
	│       │   ├── index
	│       │   │   └── image.png
	│       │   ├── hoge
	│       │   │   ├── image.png
	│       │   │   └── fuga
	│       │   │       └── image.png
	│       │   └── image.png
	│       ├── scripts
	│       │   ├── coffee
	│       │   │   ├── common.coffee
	│       │   │   ├── hoge.coffee
	│       │   │   ├── index.coffee
	│       │   │   └── modules
	│       │   ├── javascript
	│       │   │   └── javascript.js
	│       │   └── plugin
	│       │       └── plugin.js
	│       ├── stylesheets
	│       │   ├── _hoge_fuga.scss
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
	│           ├── hoge_fuga.ect
	│           ├── hoge.ect
	│           ├── index.ect
	│           └── pages.json
	└── tasks
	    ├── gulp.config.coffee
	    ├── script
	    │   ├── getTime.coffee
	    │   └── getTimeStamp.coffee
	    ├── webpack.config.base.coffee
	    ├── webpack.config.pc.coffee
	    ├── webpack.config.rp.coffee
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
	├── rp
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
	│   ├── rp
	│   │   ├── css
	│   │   ├── images
	│   │   └── js
	│   ├── pc
	│   │   ├── css
	│   │   ├── images
	│   │   └── js
	│   └── sp
	│       ├── css
	│       ├── images
	│       └── js
	└── sp

<u>**v1.3.3 から assets フォルダの名称および設置場所を自由に出来るようになりました。**</u>

> 初期値は上記のようなディレクトリ構成になっていますが
app.config.json に ASSETS_DIR の項目が追加されたことによって
assets フォルダの名称および設置場所を自由に変更出来るようになりました。

## Dependencies

- [NodeJS](https://nodejs.org/en/)
- [Gulp](http://gulpjs.com/)
- [npm](https://www.npmjs.com/)
- [Yarn](https://yarnpkg.com/)
- [ect](http://ectjs.com/)
- [Scss](http://sass-lang.com/)
- [PostCSS](http://postcss.org/)
- [CoffeeScript](http://coffeescript.org/)
- [webpack](https://webpack.js.org/)
- [Browsersync](https://www.browsersync.io/)

## Issues

- [GitHub Issues](https://github.com/glitchworker/spresso/issues)

## Thanks

- [Adobe Blank](https://github.com/adobe-fonts/adobe-blank)

## Important Notices

<u>**v1.3.4 から JSON で扱う項目名を全て大文字に変更しました。**</u>

> Gulp から受け渡す名称と、JSON に記述されている名称で大文字と小文字が混在している状況になり
ルール化する為に全て大文字で統一いたしました。そのため一部項目名を変更している部分があるので
お手数ですが README.md の再読をよろしくお願い致します。

<u>**v1.3.2 および v1.3.3 から ディレクトリやタスク処理を大幅に変更しました。**</u>

> より汎用性と自動化をはかるためにファイルやフォルダ構成の整理を含む
各 json ファイルや gulp.config.coffee などの内部的処理を大幅に変更しました。
マイナーアップデートでありながらも規定値の設定方法などガラッと変わっていますのでご注意ください。
変数等の名称に変更があるので、お手数ですが README.md の再読をよろしくお願い致します。

<u>**v1.3.0 から src フォルダの app.config.json のレスポンシブ切り替え用の項目を Boolean 型に変更しました。**</u>

> ```RESPONSIVE_TEMPLATE``` に設定するものは、 true または false を入力してください。

<u>**v1.2.7 から新たに src フォルダの app.config.json にレスポンシブ切り替え用の項目が追加されました。**</u>

> ```RESPONSIVE_TEMPLATE``` の項目に何でも良いので入力されている場合、PC用とSP用のビルドはスキップされ
レスポンシブ用のテンプレートのみビルド対象になります。

<u>**v1.1.0 から新たに src フォルダに import フォルダが追加されました。**</u>

> この中にファイル又はフォルダを追加し data.json に設定を記述することによって
本テンプレート以外にユーザーが自由に設定したファイル＆フォルダを htdocs に出力することが可能です。
フォルダの場合は type に ```dir``` ファイルの場合は ```file``` を記述し data にフォルダ名またはファイル名を入力した後
```output``` の項目に出力先のパスを入力することによって書き出されます。

## Version History

### v1.3.4（2018年2月28日）
- pages.json 内の項目を全て大文字で統一化
- 上記に伴い gulp.config.coffee 内の処理および ect の各変数の調整
- README.md の修正（Version History に開発年度と日時を追加）

### v1.3.3（2018年2月27日）
- package.json に if-webpack-plugin を追加（Webpack の Plugins 内で条件分岐が出来るようにする）
- 上記に伴い webpack.config.base.coffee 内の条件分岐周りを調整
- jQuery のバージョンを 3.2.1 から 3.3.1 に更新
- app.config.json に CURRENT_DIR の項目を追加（ディレクトリ名の最後は必ず / で閉じる）
- 上記に伴い相対パスを内部的に取得するようになった為、 pages.json から path の項目を削除
- ect で呼び出せる変数に RELATIVE_PATH を追加（動的に取得された相対パスを取得）
- app.config.json に ASSETS_DIR の項目を追加（ディレクトリ名の最後は必ず / で閉じる）
- 上記に伴い assets フォルダの名称および設置場所を自由に出来るように変更
- gulp.config.coffee に BASE_SITE_URL を追加
- 未使用のファイルなどを削除＆整理
- gulp.config.coffee の BrowserSync の設定に startPath を追加
- gulp.congif.coffee の postcss-assets のパス設定が間違えていたのを修正
- app.config.json に ABSOLUTE_PATH の項目を追加（サイト全体を絶対パスにする場合の設定）
- README.md の修正

### v1.3.2（2018年2月27日）

- package.json の全バージョンの更新（coffeescript 以外）
- iPhoneX の UserAgent 振り分けを Selector.coffee に追加
- iPhoneX の SafeArea 対応（UIWebViewにも対応する為、UserAgent を使用し動的なメディアクエリを追加）
- pages.json の META_VIEWPORT に minimum-scale=1 と viewport-fit=cover を追加
- pages.json の META_VIEWPORT から user-scalable=no と minimal-ui を削除
- _reset.scss に inlinefix の追加（inline-block の隙間を Adobe Blank で解決）
- レスポンシブ用の pages.json の redirect の項目を削除
- アダプティブ用の REDIRECT_PATH の処理を調整
- 上記に伴い、canonical と alternate タグの見直し
- gulp-sass の function で変数を読み込んでいたのを gulp-header を使用して gulp 内で完結するように変更
- section-wrapper で要素を囲うように templates を修正
- gulp.config.coffee の postcss の処理を調整（相対パスの修正）
- _reset.scss に main 要素への display: block; を追加（一部 InternetExplorer では main 要素は inline の為）
- 全てのサンプルコードの見直し
- README.md の修正

### v1.3.1（2017年12月11日）

- package.json の全バージョンの更新（coffeescript 以外）
- utils に tooltips の scss を追加
- README.md の修正

### v1.3.0（2017年11月16日）

- package.json の全バージョンの更新（coffeescript 以外）
- mixin の fonsSize に font_vw() & font_calc() 関数を追加
- mixin にCSS3アニメーション時のチラツキを治す css3fix() 関数を追加
- common.coffee の LINE シェアロジックを PC 用と SP 用に振り分けるように実装
- common.coffee に Google+ 用のシェア追加
- iOS 9 での viewport の設定で inital-scale が無視されるのを shrink-to-fit=no を追加して対応
- meta タグに googlebot のGoogle検索用のボットを追加
- app.config.json の RESPONSIVE_TEMPLATE 項目を Boolean 型に変更
- README.md の修正

### v1.2.9（2017年9月1日）

- package.json の全バージョンの更新
- coffee-loader を 0.8.0 にした際のモジュールエラーを修正
- 上記に伴い coffee-script から coffeescript に変更
- README.md の修正

### v1.2.8（2017年8月4日）

- 文字をカーニング調整するスクリプトを Common に追加
- カーニングしたい要素に kerning のクラス名を追加すれば自動的に使用出来ます。
- 各 src 内の coffee 内に common.coffee のファイルを追加
- README.md の修正

### v1.2.7（2017年7月28日）

- レスポンシブ用のテンプレートを導入
- 上記に伴い app.config.json にて RESPONSIVE_TEMPLATE の切り替え項目を追加
- scss 関係の要素の整理
- README.md の修正

### v1.2.6（2017年7月25日）

- head タグのテンプレート更新
- jQuery Core を最新にアップデート
- package.json の run-sequence の更新
- README.md の修正

### v1.2.5（2017年7月25日）

- head タグのテンプレート更新
- package.json の全バージョンの更新
- README.md の修正

### v1.2.4（2017年7月20日）

- postcss の変数を初回ビルド時に使用した場合エラーが起きていたのを修正
- package.json の全バージョンの更新
- README.md の修正

### v1.2.3（2017年7月4日）

- SNSシェアボタン処理の実装（Twitter、Facebook、LINE）
- package.json の全バージョンの更新
- README.md の修正

### v1.2.2（2017年6月20日）

- package.json の全バージョンの更新
- README.md の修正

### v1.2.1（2017年4月19日）

- postcss の形式に変換する scss function を削除（どうやら無くても大丈夫みたい？）
- postcss の resolve(), width(), height(), size(), inline() を scss で利用可能
- resolve() が追加されたことによって、images フォルダ以下のパスのみで取得出来るように変更
- plumberConfig 関数を追加し、エラーが出ても必ずタスクは継続されるように変更
- README.md の修正

### v1.2.0（2017年4月19日）

- gulp-util & gulp-postcss & postcss-assets & postcss-calc & postcss-sorting & css-mqpacker を追加
- gulp.config.coffee に postcss の記述を追加
- postcss のエラー時 gulp を止めないように gulp-util を追加
- 同一の mediaqueries を一つにまとめる css-mqpacker を追加
- css のプロパティ順を指定した並びに変更する postcss-sorting を追加
- postcss の形式に変換する scss function の作成
- postcss の width(), height(), size(), inline() を scss で呼び出す
- 上記 scss の function と衝突しないように w(), h(), s(), i() で使用可能
- w(), h(), s() に関しては、第二引数に数値を入れることによって割る事が出来ます。
- README.md の修正

### v1.1.9（2017年4月18日）

- imagemin を一時的にコメントアウト
- package.json の全バージョンの更新
- README.md の修正

### v1.1.8（2017年3月9日）

- common.coffee に getParam() shuffleArray() splitByLength() の共通関数を追加
- 上記の getParam() はURLからパラメータを取得する
- 上記の shuffleArray() は配列をシャッフルする
- 上記の splitByLength() は指定した文字数で分割し配列で返す
- package.json の更新
- README.md の修正

### v1.1.7（2017年3月8日）

- yarn run start-prod の コマンドを追加
- gulp.config.coffee の pathArray のロジック変更（ビルド時に htdocs 内を綺麗にするように）
- gulp-sass-glob を一時的に削除（app.scss に @include を記述するスタイルに変更）
- WebPack 圧縮時にコンストラクタ名が省略されるため、constructor.name が動いていなかったのを修正
- hoge の他に fuga のサンプルディレクトリも追加
- meta タグの旧IE用コンディショナルコメントを pages.json 項目で個別に有効・無効出来るように変更
- README.md の修正

### v1.1.6（2017年2月12日）

- gulp-sass-glob が Windows で正常に動いていなかったのを修正
- README.md の修正

### v1.1.5（2017年2月1日）

- gulp のタスクで画像関連が機能していなかったのを修正
- LICENSE の copyright の修正

### v1.1.4（2017年1月27日）

- gulp-sass-glob の追加
- sass の @import における glob を有効にする
- package.json の更新

### v1.1.3（2016年12月23日）

- Selector.coffee に iPhone 機種判別処理実装
- package.json の更新

### v1.1.2（2016年12月22日）

- タスク実行コマンドの大幅変更
- webpack.config.xxxx.coffee 設定の調整
- package.json の更新
- README.md の修正

### v1.1.1（2016年12月21日）

- meta タグの lang 属性を指定出来るように変更
- webpack.config.xxxx.coffee 設定の最適化
- README.md の修正

### v1.1.0（2016年12月20日）

- インポートデータ機能の追加
- package.json の更新
- README.md の修正

### v1.0.0（2016年12月19日）

- webpack.config.base.coffee の追加（共通設定）
- 正式リリース

### v0.2.1（2016年12月15日）

- webpack-merge のパッケージを追加（webpack.config ファイルの設定を共通化させるため）
- sp の viewport を変更
- addScripts を addScriptsHeader と addScriptsFooter に分け上下にタグを追加出来るように変更
- package.json の更新

### v0.2.0（2016年12月12日）

- yarn run zip を yarn run export に変更
- gulp.config.coffee の整理
- pages.json に redirect の項目を追加（リダイレクトさせたくないページを個別に設定）
- package.json の更新
- README.md の修正

### v0.1.9（2016年12月6日）

- 差分を書き出す際に、更新日時ではなく SHA1 で比較するように変更
- UPDATE または TIMESTAMP を含めていると差分が取れないので一旦コメントアウト
- temp フォルダを作る方法を変更（ yarn run diff ）で一時フォルダ作成

### v0.1.8（2016年12月5日）

- build タスクを並列処理から直列処理に変更（pathSearch 関数の競合回避の為）
- package.json の更新
- README.md の修正

### v0.1.7（2016年12月5日）

- ect のタスクがちゃんと出力されていなかったのを修正
- package.json のプラグインを名前順に変更
- Gulp のタスクを大幅に変更＆コメント記述

### v0.1.6（2016年12月2日）

- html の削除部分で稀にエラーが出ていたのを修正
- pathSearch の実装方法の変更（フォルダが深くなっても反映されるように）
- Gulp タスクのロジック周りの微調整

### v0.1.5（2016年12月2日）

- 差分データを zip ファイルに出力するタスク実装
- 上記に伴い、archives と temp フォルダを削除するタスク実装
- scss でエラーが出てもタスクが止まらないように変更
- scss に MediaQueries の mixin を追加
- pathSearch を実装した事によって、src と htdocs のファイルの変更＆削除の同期処理を実装
- 上記の実装を使って、本番ビルド時に sourcemaps の map ファイルを削除

### v0.1.4（2016年11月28日）

- scss の サイトURLの取得を #{$SITE_URL} に統一するようにタスクを変更
- meta タグの name 属性の author を pages.json 項目未入力の場合非表示にするように変更
- meta タグの lang 属性をページ別に pages.json を変更することを可能にし、多言語ページ対応
- stylesheets と templates のディレクトリ構造を統一化
- meta タグに Google+ を追加
- body タグのページクラス名の接頭辞に page- を付けるように変更（クラス名の被り防止の為）
- package.json の更新
- README.md の修正

### v0.1.3（2016年11月18日）

- pages.json の meta 情報を入れ子で取得するように変更
- BrowserSync の log 出力にプロジェクト名（サイト名）で表示するように変更
- scss を css 変更後にリロードするようにしていたのを stream に流してリアルタイムに反映するように変更
- ect を html 変更後にリロードするようにしていたのを stream に流してリアルタイムに反映するように変更
- coffee を js 変更後にリロードするようにしていたのを stream に流してリアルタイムに反映するように変更
- README.md の修正

### v0.1.2（2016年11月18日）

- js を結合する際の順番を plugin javascript coffee の順番に変更（優先度の確立）
- リダイレクト処理を大幅に変更＆パラメータに対応

### v0.1.1（2016年11月14日）

- sourcemaps が本番ビルド時に sass に残っていたのを修正
- uglify で圧縮するタイミングを webpack 内に移動（Gulp 側で実行すると怒られる為）
- 全ての BrowserSync のリロードタイミングをファイル出力後に変更
- WebPack で複数の coffee を扱う際、自身のコンストラクタ名を取得し該当ページで実行されるように変更
- README.md の修正

### v0.1.0（2016年11月11日）

- sourcemaps のタイミングが間違っていたのを修正
- ビルド対象を拡張子で厳密に判断するように変更

### v0.0.9（2016年11月10日）

- gulp.config.coffee の調整
- ect のタイムラグ対策に html ファイルが更新されたらリロードするように変更

### v0.0.8（2016年11月10日）

- gulp-changed & gulp-imagemin & gulp-watch 追加
- 上記を使い src ディレクトリで一元管理するように変更
- gulp-chenged により差分比較での出力に対応（画像系＆pages.json はファイル変更後に反映）
- gulp-watch により image ディレクトリの新規追加の監視に対応
- package の整理（gulp-filesize 削除）
- pages.json の更新
- README.md の修正

### v0.0.7（2016年10月24日）

- packageの整理（jQuery と underscore 削除）
- gulp-header & gulp-footer 追加
- 上記を使いストリーム中のファイル先頭にコメント挿入
- BrowserSync の設定調整

### v0.0.6（2016年10月24日）

- BrowserSync のバグを修正

### v0.0.5（2016年10月24日）

- package.json 修正
- Gulpタスクの処理を調整
- README.mdの修正

### v0.0.4（2016年9月26日）

- package.json バージョン更新
- templates/base/_head.ect の調整
- README.md の修正

### v0.0.3（2016年7月19日）

- WebPack の設定情報変更
- DefinePlugin の設定変更
- デバッグコードを削除するように uglify 設定変更
- SCSSの mixin と utils を追加

### v0.0.2（2016年6月28日）

- タスクファイル分割
- 不要なファイルの整理

### v0.0.1（2016年6月8日）

- 初回リリース

### vX.X.X（2015年9月18日）

- 開発スタート