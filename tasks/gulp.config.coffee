#------------------------------------------------------
# Load dependencies module
# 依存モジュール読み込み
#------------------------------------------------------

path = require 'path' # パス解析
g = require 'gulp' # Gulp 本体
$ = do require 'gulp-load-plugins' # package.json からプラグインを自動で読み込む
fs = require 'fs' # ファイルやディレクトリの操作
url = require 'url' # URL をパースする

rimraf = require 'rimraf' # 単一ファイル / ディレクトリ削除
del = require 'del' # 複数ファイル / ディレクトリ削除
minimist = require 'minimist' # Gulp で引数を解析
eventStream = require 'event-stream' # Gulp のイベントを取得する

bs = require('browser-sync').create() # Web サーバー作成
ssi = require 'connect-ssi' # SSI を有効化
jsonServer = require 'gulp-json-srv' # API サーバー作成

webpack = require 'webpack' # Webpack 読み込み
webpackStream = require 'webpack-stream' # Gulp で Webpack を読み込む

#------------------------------------------------------
# Load original module
# 独自モジュール読み込み
#------------------------------------------------------

appConfig = require '../src/app.config.json' # サイト共通設定
update = do require './script/getTime' # 現在日時取得
timestamp = do require './script/getTimeStamp' # 現在タイムスタンプ取得

#------------------------------------------------------
# Development & Production Environment Branch processing
# 開発＆本番環境の振り分け処理
#------------------------------------------------------

options = minimist process.argv.slice(2), envOption

envOption =
  string: 'env'
  default: env: process.env.NODE_ENV or 'development'

isProduction = if options.env == 'production' or options.env == 'staging' then true else false
isStaging = if options.env == 'staging' then true else false

if isProduction
  # SourceMap
  isSourcemap = false
  isSourcemapOutput = true
  # BASE URL
  if isStaging
    APP_SITE_URL = appConfig.STG_SITE_URL
  else
    APP_SITE_URL = appConfig.PROD_SITE_URL
else
  # SourceMap
  isSourcemap = true
  isSourcemapOutput = '.'
  # BASE URL
  APP_SITE_URL = appConfig.DEV_SITE_URL

#------------------------------------------------------
# Additional settings of appConfig
# appConfig の追加設定
#------------------------------------------------------

appConfig.UPDATE = update # app.config.json に UPDATE 項目を追加
appConfig.TIMESTAMP = timestamp # app.config.json に TIMESTAMP 項目を追加
appConfig.BASE_SITE_URL = APP_SITE_URL # app.config.json に BASE_SITE_URL 項目を追加
appConfig.APP_SITE_URL = APP_SITE_URL + appConfig.CURRENT_DIR # app.config.json に APP_SITE_URL 項目を追加
appConfig.RESPONSIVE_TEMPLATE = Boolean(appConfig.RESPONSIVE_TEMPLATE) # app.config.json の RESPONSIVE_TEMPLATE 項目を Boolean 型に変換
appConfig.ABSOLUTE_PATH = Boolean(appConfig.ABSOLUTE_PATH) # app.config.json の ABSOLUTE_PATH 項目を Boolean 型に変換
appConfig.API_SERVER = Boolean(appConfig.API_SERVER) # app.config.json の API_SERVER 項目を Boolean 型に変換

#------------------------------------------------------
# Path Settings
# パス設定
#------------------------------------------------------

rootDir =
  src: 'src'
  htdocs: 'htdocs'
  assets: appConfig.ASSETS_DIR
  archive: 'archives'
  temp: 'temp'

paths =
  common:
    js:
      plugin: rootDir.src + '/common/scripts/plugin/**/*.js'
      javascript: rootDir.src + '/common/scripts/javascript/**/!(_)*.js'
      coffee: rootDir.src + '/common/scripts/coffee/**/!(_)*.coffee'
      dest: rootDir.htdocs + '/' + rootDir.assets + 'common/js/'
    img:
      src: rootDir.src + '/common/images/**/*.*'
      postcss: rootDir.assets + 'common/images/'
      dest: rootDir.htdocs + '/' + rootDir.assets + 'common/images/'
    libCopy:
      lib: rootDir.src + '/common/scripts/lib/**/*.js'
      dest: rootDir.htdocs + '/' + rootDir.assets + 'common/js/lib/'
    import:
      json: rootDir.src + '/import/data.json'
  rp:
    dest: rootDir.htdocs + '/'
    ect:
      json: rootDir.src + '/rp/templates/pages.json'
      watch: rootDir.src + '/rp/templates/**/*.ect'
    css:
      concat: 'app.css'
      sass: rootDir.src + '/rp/stylesheets/app.scss'
      watch: rootDir.src + '/rp/stylesheets/**/*.scss'
      postcss: rootDir.assets + 'rp/css/'
      dest: rootDir.htdocs + '/' + rootDir.assets + 'rp/css/'
    js:
      plugin: rootDir.src + '/rp/scripts/plugin/**/*.js'
      javascript: rootDir.src + '/rp/scripts/javascript/**/!(_)*.js'
      coffee: rootDir.src + '/rp/scripts/coffee/**/!(_)*.coffee'
      dest: rootDir.htdocs + '/' + rootDir.assets + 'rp/js/'
    img:
      src: rootDir.src + '/rp/images/**/*.*'
      postcss: rootDir.assets + 'rp/images/'
      dest: rootDir.htdocs + '/' + rootDir.assets + 'rp/images/'
  pc:
    dest: rootDir.htdocs + '/'
    ect:
      json: rootDir.src + '/pc/templates/pages.json'
      watch: rootDir.src + '/pc/templates/**/*.ect'
    css:
      concat: 'app.css'
      sass: rootDir.src + '/pc/stylesheets/app.scss'
      watch: rootDir.src + '/pc/stylesheets/**/*.scss'
      postcss: rootDir.assets + 'pc/css/'
      dest: rootDir.htdocs + '/' + rootDir.assets + 'pc/css/'
    js:
      plugin: rootDir.src + '/pc/scripts/plugin/**/*.js'
      javascript: rootDir.src + '/pc/scripts/javascript/**/*.js'
      coffee: rootDir.src + '/pc/scripts/coffee/**/!(_)*.coffee'
      dest: rootDir.htdocs + '/' + rootDir.assets + 'pc/js/'
    img:
      src: rootDir.src + '/pc/images/**/*.*'
      postcss: rootDir.assets + 'pc/images/'
      dest: rootDir.htdocs + '/' + rootDir.assets + 'pc/images/'
  sp:
    dest: rootDir.htdocs + '/sp/'
    ect:
      json: rootDir.src + '/sp/templates/pages.json'
      watch: rootDir.src + '/sp/templates/**/*.ect'
    css:
      concat: 'app.css'
      sass: rootDir.src + '/sp/stylesheets/app.scss'
      watch: rootDir.src + '/sp/stylesheets/**/*.scss'
      postcss: rootDir.assets + 'sp/css/'
      dest: rootDir.htdocs + '/' + rootDir.assets + 'sp/css/'
    js:
      plugin: rootDir.src + '/sp/scripts/plugin/**/*.js'
      javascript: rootDir.src + '/sp/scripts/javascript/**/!(_)*.js'
      coffee: rootDir.src + '/sp/scripts/coffee/**/!(_)*.coffee'
      dest: rootDir.htdocs + '/' + rootDir.assets + 'sp/js/'
    img:
      src: rootDir.src + '/sp/images/**/*.*'
      postcss: rootDir.assets + 'sp/images/'
      dest: rootDir.htdocs + '/' + rootDir.assets + 'sp/images/'
  archive:
    src: rootDir.htdocs + '/**/*'
    temp: rootDir.temp + '/'
    dest: rootDir.archive + '/'
  api:
    port: 9000
    src: './' + rootDir.src + '/api/'
    watch: rootDir.src + '/api/**/*.json'
    dest: '/api'

#------------------------------------------------------
# Comment information Settings
# コメント情報の設定
#------------------------------------------------------

commentsCss = [
  '/* --------------------------------------------------------'
  ' Name:      <%= pkg.SITE_NAME %> - <%= filename %>'
  ' Author:    <%= pkg.AUTHOR %>'
  # ' Update:    <%= pkg.UPDATE %>'
  ' Info:      <%= pkg.SITE_NAME %>'
  '----------------------------------------------------------- */'
  ''
].join('\n')

commentsJs = [
  '/*!'
  ' * <%= pkg.SITE_NAME %> - <%= filename %>'
  ' * --------------------'
  # ' * @update <%= pkg.UPDATE %>'
  ' * @author <%= pkg.AUTHOR %>'
  ' * @link ' + appConfig.APP_SITE_URL
  ' * --------------------'
  ' */'
  ''
].join('\n')

#------------------------------------------------------
# Get filepath Settings
# ファイルパスを取得
#------------------------------------------------------

pathArray = []
pathSearch = (dir, dirName) ->
  # import で追加されたデータは削除対象外にする
  jsonData = JSON.parse fs.readFileSync(paths.common.import.json)
  jsonData.forEach (page, i) ->
    pathArray.push '!'+ rootDir.htdocs + page.output + page.data
  # src と htdocs フォルダの比較をする
  eventStream.map (file, done) ->
    filePath = $.slash(file.path)
    fileDir = filePath.match(dir + '.*')[0]
    if dirName == 'templates'
      if appConfig.RESPONSIVE_TEMPLATE
        fileReplace = fileDir.replace(rootDir.src + '/', paths.rp.dest).replace('/rp', '').replace('/templates', '')
      else
        fileReplace = fileDir.replace(rootDir.src + '/', paths.pc.dest).replace('/pc', '').replace('/templates', '')
    else if dirName == 'images'
      fileReplace = fileDir.replace(rootDir.src + '/', paths.pc.dest + '/' + rootDir.assets)
    else if dirName == 'js' or dirName == 'css'
      fileReplace = fileDir
    pathArray.push '!' + fileReplace
    done()
    return

#------------------------------------------------------
# Convert absolute path to relative path
# 絶対パスから相対パスに変換
#------------------------------------------------------

abspath2rel = (base_path, target_path) ->
  tmp_str = ''
  base_path = base_path.split('/')
  base_path.pop()
  target_path = target_path.split('/')
  while base_path[0] == target_path[0]
    base_path.shift()
    target_path.shift()
  i = 0
  while i < base_path.length
    tmp_str += '../'
    i++
  tmp_str + target_path.join('/')

#------------------------------------------------------
# Plumber Settings
# Plumber でエラーが出た時に止めないようにする
#------------------------------------------------------

plumberConfig = (error) ->
  console.log error
  @emit 'end'
  return

#------------------------------------------------------
# Common Settings
# 共通設定
#------------------------------------------------------

# data import process
importData = (done) ->
  jsonData = JSON.parse fs.readFileSync(paths.common.import.json)
  jsonData.forEach (page, i) ->
    if page.TYPE == 'dir'
      g.src rootDir.src + '/import/' + page.DATA + '/**/*', { allowEmpty: true }
      .pipe $.plumber(plumberConfig)
      .pipe $.changed(page.OUTPUT, { hasChanged: $.changed.compareContents })
      .pipe g.dest rootDir.htdocs + '/' + page.OUTPUT
    else
      g.src rootDir.src + '/import/' + page.DATA, { allowEmpty: true }
      .pipe $.plumber(plumberConfig)
      .pipe $.changed(page.OUTPUT, { hasChanged: $.changed.compareContents })
      .pipe g.dest rootDir.htdocs + '/' + page.OUTPUT
  done()

# lib copy process
libCopy = ->
  g.src paths.common.libCopy.lib
  .pipe $.changed(paths.common.libCopy.dest)
  .pipe g.dest paths.common.libCopy.dest

# coffee compile process
coffeeCompile = ->
  g.src([paths.common.js.plugin, paths.common.js.javascript, paths.common.js.coffee])
  .pipe $.plumber(plumberConfig)
  .pipe webpackStream require('./webpack.config.common.coffee'), webpack
  .pipe $.if isProduction, $.header(commentsJs, pkg: appConfig, filename: '共通スクリプト')
  .pipe g.dest paths.common.js.dest
  # JS を stream オプションでリアルタイムに反映
  .pipe bs.stream()
  # sourcemaps を本番ビルド時に削除する
  .pipe $.if isProduction, pathSearch(paths.common.js.dest, 'js').on 'end', (cb) ->
    pathArray.unshift(paths.common.js.dest + '**/*.map')
    return

# img file check
imgCheck = ->
  g.src paths.common.img.src
  .pipe $.plumber(plumberConfig)
  # src フォルダに存在しないファイルを htdocs から削除する
  .pipe pathSearch(rootDir.src + '/common/images/', 'images').on 'end', (cb) ->
    pathArray.unshift(paths.common.img.dest + '**/*.*')
    return

# img optimize
imgCompile = ->
  g.src paths.common.img.src
  .pipe $.plumber(plumberConfig)
  # 画像に変更がない場合、出力しない
  .pipe $.changed(paths.common.img.dest, { hasChanged: $.changed.compareContents })
  # .pipe $.imagemin()
  .pipe g.dest paths.common.img.dest

#------------------------------------------------------
# Setting for Responsive
# Responsive 向け設定
#------------------------------------------------------

# ect json process rp
ectRP = (done) ->
  jsonData = JSON.parse fs.readFileSync(paths.rp.ect.json)
  jsonDataLength = Object.keys(jsonData).length - 1
  jsonData.forEach (page, i) ->
    g.src rootDir.src + '/rp/templates/' + page.TEMPLATE_ECT + '.ect'
    .pipe $.plumber(plumberConfig)
    # ect で JSON ファイルを変数に読み込む
    .pipe $.data (file)->
      staticData = page
      # サイトのURLおよびサイト名の取得
      staticData.BASE_SITE_URL = appConfig.BASE_SITE_URL
      staticData.SITE_URL = appConfig.APP_SITE_URL
      staticData.SITE_NAME = appConfig.SITE_NAME
      # ディレクトリの相対パス、アセットディレクトリのパスを取得
      if appConfig.ABSOLUTE_PATH
        staticData.RELATIVE_PATH = '/' + appConfig.CURRENT_DIR
      else
        staticData.RELATIVE_PATH = abspath2rel appConfig.CURRENT_DIR, '' + abspath2rel staticData.PATH_FILENAME, ''
      staticData.ASSETS_DIR = appConfig.ASSETS_DIR
      # 'index.html' を含まないファイルパスを出す
      staticData.FILE_PATH = staticData.PATH_FILENAME.replace appConfig.CURRENT_DIR, ''
      staticData.FILE_PATH = staticData.FILE_PATH.replace 'index.html', ''
      return staticData
    .pipe $.ect(data: page)
    # pages.json に記述された 'PATH_FILENAME' で決めたパスに出力
    .pipe $.rename appConfig.CURRENT_DIR + page.PATH_FILENAME
    # html 内の img 要素の src が *.svg の場合インラインで出力
    .pipe $.injectSvg base: paths.rp.dest + appConfig.ASSETS_DIR
    .pipe g.dest paths.rp.dest
    # html を stream オプションでリアルタイムに反映
    .pipe bs.stream()
    # src フォルダに存在しないファイルを htdocs から削除する
    .pipe pathSearch(paths.rp.dest, 'templates').on 'end', (cb) ->
      if i == jsonDataLength
        pathArray.unshift('!' + paths.rp.dest + 'index.html')
        pathArray.unshift(paths.rp.dest + '**/*.html')
      return
  done()

# sass compile process rp
cssRP = ->
  g.src paths.rp.css.sass, { sourcemaps: isSourcemap }
  .pipe $.plumber(plumberConfig)
  # gulp-header を使用して JSON ファイルを sass 変数に読み込む
  .pipe $.header(
    '$BASE_SITE_URL: "' + appConfig.BASE_SITE_URL + '";\n' +
    '$SITE_URL: "' + appConfig.APP_SITE_URL + '";\n' +
    '$SITE_NAME: "' + appConfig.SITE_NAME + '";\n' +
    '$AUTHOR: "' + appConfig.AUTHOR + '";\n' +
    '$MODIFIER: "' + appConfig.MODIFIER + '";\n' +
    '$UPDATE: "' + appConfig.UPDATE + '";\n' +
    '$TIMESTAMP: "?v=' + appConfig.TIMESTAMP + '";\n'
  )
  .pipe $.sass({
    outputStyle: 'expanded'
  }).on('error', $.sass.logError) # エラーでも止めない
  # postcss で画像サイズを取得し変換する
  .pipe $.postcss([
    require('postcss-assets')(
      basePath: paths.rp.dest # 公開フォルダのパス
      loadPaths: [paths.common.img.postcss, paths.rp.img.postcss] # basePath からみた images フォルダの位置
      relative: if not appConfig.ABSOLUTE_PATH then paths.rp.css.postcss # basePath と対になる css フォルダの位置
    )
    require('css-mqpacker')
    require('postcss-sorting')(
      require '../src/postcss-sorting.json' # 並び順の設定ファイル
    )
  ]).on('error', $.util.log) # エラーでも止めない
  .pipe $.autoprefixer overrideBrowserslist: ['> 0%']
  .pipe $.concat paths.rp.css.concat
  .pipe $.if isProduction, $.cleanCss({compatibility: 'ie8'})
  .pipe $.if isProduction, $.header(commentsCss, pkg: appConfig, filename: paths.rp.css.concat)
  .pipe g.dest paths.rp.css.dest, if not isProduction then { sourcemaps: isSourcemapOutput }
  # CSS を stream オプションでリアルタイムに反映
  .pipe bs.stream()
  # sourcemaps を本番ビルド時に削除する
  .pipe $.if isProduction, pathSearch(paths.rp.css.dest, 'css').on 'end', (cb) ->
    pathArray.unshift(paths.rp.css.dest + '**/*.map')
    return

# coffee compile process rp
coffeeRP = ->
  g.src([paths.rp.js.plugin, paths.rp.js.javascript, paths.rp.js.coffee])
  .pipe $.plumber(plumberConfig)
  .pipe webpackStream require('./webpack.config.rp.coffee'), webpack
  .pipe $.if isProduction, $.header(commentsJs, pkg: appConfig, filename: 'メインスクリプト')
  .pipe g.dest paths.rp.js.dest
  # JS を stream オプションでリアルタイムに反映
  .pipe bs.stream()
  # sourcemaps を本番ビルド時に削除する
  .pipe $.if isProduction, pathSearch(paths.rp.js.dest, 'js').on 'end', (cb) ->
    pathArray.unshift(paths.rp.js.dest + '**/*.map')
    return

# img check rp
imgCheckRP = ->
  g.src paths.rp.img.src
  .pipe $.plumber(plumberConfig)
  # src フォルダに存在しないファイルを htdocs から削除する
  .pipe pathSearch(rootDir.src + '/rp/images/', 'images').on 'end', (cb) ->
    pathArray.unshift(paths.rp.img.dest + '**/*.*')
    return

# img optimize rp
imgCompileRP = ->
  g.src paths.rp.img.src
  .pipe $.plumber(plumberConfig)
  # 画像に変更がない場合、出力しない
  .pipe $.changed(paths.rp.img.dest, { hasChanged: $.changed.compareContents })
  # .pipe $.imagemin()
  .pipe g.dest paths.rp.img.dest

# build rp
buildRP = (done) ->
  g.series 'lib', 'coffee', 'img', 'coffee-rp', 'img-rp', 'ect-rp', 'css-rp', 'remove-files', 'import'
  done()

#------------------------------------------------------
# Setting for PC
# PC 向け設定
#------------------------------------------------------

# ect json process pc
ectPC = (done) ->
  jsonData = JSON.parse fs.readFileSync(paths.pc.ect.json)
  jsonDataLength = Object.keys(jsonData).length - 1
  jsonData.forEach (page, i) ->
    g.src rootDir.src + '/pc/templates/' + page.TEMPLATE_ECT + '.ect'
    .pipe $.plumber(plumberConfig)
    # ect で JSON ファイルを変数に読み込む
    .pipe $.data (file)->
      staticData = page
      # サイトのURLおよびサイト名の取得
      staticData.BASE_SITE_URL = appConfig.BASE_SITE_URL
      staticData.SITE_URL = appConfig.APP_SITE_URL
      staticData.SITE_NAME = appConfig.SITE_NAME
      # ディレクトリの相対パス、アセットディレクトリのパスを取得
      if appConfig.ABSOLUTE_PATH
        staticData.RELATIVE_PATH = '/' + appConfig.CURRENT_DIR
      else
        staticData.RELATIVE_PATH = abspath2rel appConfig.CURRENT_DIR, '' + abspath2rel staticData.PATH_FILENAME, ''
      staticData.ASSETS_DIR = appConfig.ASSETS_DIR
      # 'index.html' を含まないファイルパスを出す
      staticData.FILE_PATH = staticData.PATH_FILENAME.replace appConfig.CURRENT_DIR, ''
      staticData.FILE_PATH = staticData.FILE_PATH.replace 'index.html', ''
      # 'index.html' を含まないリダイレクトパスを出す
      staticData.REDIRECT_PATH = staticData.RELATIVE_PATH + 'sp/' + appConfig.CURRENT_DIR + staticData.PATH_FILENAME.replace 'index.html', ''
      return staticData
    .pipe $.ect(data: page)
    # pages.json に記述された 'PATH_FILENAME' で決めたパスに出力
    .pipe $.rename appConfig.CURRENT_DIR + page.PATH_FILENAME
    # html 内の img 要素の src が *.svg の場合インラインで出力
    .pipe $.injectSvg base: paths.pc.dest + appConfig.ASSETS_DIR
    .pipe g.dest paths.pc.dest
    # html を stream オプションでリアルタイムに反映
    .pipe bs.stream()
    # src フォルダに存在しないファイルを htdocs から削除する
    .pipe pathSearch(paths.pc.dest, 'templates').on 'end', (cb) ->
      if i == jsonDataLength
        pathArray.unshift('!' + paths.pc.dest + 'index.html')
        pathArray.unshift('!' + paths.sp.dest + '**/*.html')
        pathArray.unshift(paths.pc.dest + '**/*.html')
      return
  done()

# sass compile process pc
cssPC = ->
  g.src paths.pc.css.sass, { sourcemaps: isSourcemap }
  .pipe $.plumber(plumberConfig)
  # gulp-header を使用して JSON ファイルを sass 変数に読み込む
  .pipe $.header(
    '$BASE_SITE_URL: "' + appConfig.BASE_SITE_URL + '";\n' +
    '$SITE_URL: "' + appConfig.APP_SITE_URL + '";\n' +
    '$SITE_NAME: "' + appConfig.SITE_NAME + '";\n' +
    '$AUTHOR: "' + appConfig.AUTHOR + '";\n' +
    '$MODIFIER: "' + appConfig.MODIFIER + '";\n' +
    '$UPDATE: "' + appConfig.UPDATE + '";\n' +
    '$TIMESTAMP: "?v=' + appConfig.TIMESTAMP + '";\n'
  )
  .pipe $.sass({
    outputStyle: 'expanded'
  }).on('error', $.sass.logError) # エラーでも止めない
  # postcss で画像サイズを取得し変換する
  .pipe $.postcss([
    require('postcss-assets')(
      basePath: paths.pc.dest # 公開フォルダのパス
      loadPaths: [paths.common.img.postcss, paths.pc.img.postcss] # basePath からみた images フォルダの位置
      relative: if not appConfig.ABSOLUTE_PATH then paths.pc.css.postcss # basePath と対になる css フォルダの位置
    )
    require('css-mqpacker')
    require('postcss-sorting')(
      require '../src/postcss-sorting.json' # 並び順の設定ファイル
    )
  ]).on('error', $.util.log) # エラーでも止めない
  .pipe $.autoprefixer overrideBrowserslist: ['> 0%']
  .pipe $.concat paths.pc.css.concat
  .pipe $.if isProduction, $.cleanCss({compatibility: 'ie8'})
  .pipe $.if isProduction, $.header(commentsCss, pkg: appConfig, filename: paths.pc.css.concat)
  .pipe g.dest paths.pc.css.dest, if not isProduction then { sourcemaps: isSourcemapOutput }
  # CSS を stream オプションでリアルタイムに反映
  .pipe bs.stream()
  # sourcemaps を本番ビルド時に削除する
  .pipe $.if isProduction, pathSearch(paths.pc.css.dest, 'css').on 'end', (cb) ->
    pathArray.unshift(paths.pc.css.dest + '**/*.map')
    return

# coffee compile process pc
coffeePC = ->
  g.src([paths.pc.js.plugin, paths.pc.js.javascript, paths.pc.js.coffee])
  .pipe $.plumber(plumberConfig)
  .pipe webpackStream require('./webpack.config.pc.coffee'), webpack
  .pipe $.if isProduction, $.header(commentsJs, pkg: appConfig, filename: 'メインスクリプト')
  .pipe g.dest paths.pc.js.dest
  # JS を stream オプションでリアルタイムに反映
  .pipe bs.stream()
  # sourcemaps を本番ビルド時に削除する
  .pipe $.if isProduction, pathSearch(paths.pc.js.dest, 'js').on 'end', (cb) ->
    pathArray.unshift(paths.pc.js.dest + '**/*.map')
    return

# img check pc
imgCheckPC = ->
  g.src paths.pc.img.src
  .pipe $.plumber(plumberConfig)
  # src フォルダに存在しないファイルを htdocs から削除する
  .pipe pathSearch(rootDir.src + '/pc/images/', 'images').on 'end', (cb) ->
    pathArray.unshift(paths.pc.img.dest + '**/*.*')
    return

# img optimize pc
imgCompilePC = ->
  g.src paths.pc.img.src
  .pipe $.plumber(plumberConfig)
  # 画像に変更がない場合、出力しない
  .pipe $.changed(paths.pc.img.dest, { hasChanged: $.changed.compareContents })
  # .pipe $.imagemin()
  .pipe g.dest paths.pc.img.dest

# build pc
buildPC = (done) ->
  g.series 'lib', 'coffee', 'img', 'coffee-pc', 'img-pc', 'ect-pc', 'css-pc', 'remove-files', 'import'
  done()

#------------------------------------------------------
# Setting for SP
# SP 向け設定
#------------------------------------------------------

# ect json process sp
ectSP = (done) ->
  jsonData = JSON.parse fs.readFileSync(paths.sp.ect.json)
  jsonDataLength = Object.keys(jsonData).length - 1
  jsonData.forEach (page, i) ->
    g.src rootDir.src + '/sp/templates/' + page.TEMPLATE_ECT + '.ect'
    .pipe $.plumber(plumberConfig)
    # ect で JSON ファイルを変数に読み込む
    .pipe $.data (file)->
      staticData = page
      # サイトのURLおよびサイト名の取得
      staticData.BASE_SITE_URL = appConfig.BASE_SITE_URL
      staticData.SITE_URL = appConfig.APP_SITE_URL
      staticData.SITE_NAME = appConfig.SITE_NAME
      # ディレクトリの相対パス、アセットディレクトリのパスを取得
      if appConfig.ABSOLUTE_PATH
        staticData.RELATIVE_PATH = '/' + appConfig.CURRENT_DIR
      else
        staticData.RELATIVE_PATH = abspath2rel appConfig.CURRENT_DIR, '' + '../' + abspath2rel staticData.PATH_FILENAME, ''
      staticData.ASSETS_DIR = appConfig.ASSETS_DIR
      # 'index.html' を含まないファイルパスを出す
      staticData.FILE_PATH = staticData.PATH_FILENAME.replace appConfig.CURRENT_DIR, ''
      staticData.FILE_PATH = staticData.FILE_PATH.replace 'index.html', ''
      # 'index.html' を含まないリダイレクトパスを出す
      staticData.REDIRECT_PATH = staticData.RELATIVE_PATH + appConfig.CURRENT_DIR + staticData.PATH_FILENAME.replace 'index.html', ''
      return staticData
    .pipe $.ect(data: page)
    # pages.json に記述された 'PATH_FILENAME' で決めたパスに出力
    .pipe $.rename appConfig.CURRENT_DIR + page.PATH_FILENAME
    # html 内の img 要素の src が *.svg の場合インラインで出力
    .pipe $.injectSvg base: paths.pc.dest + appConfig.ASSETS_DIR
    .pipe g.dest paths.sp.dest
    # html を stream オプションでリアルタイムに反映
    .pipe bs.stream()
    # src フォルダに存在しないファイルを htdocs から削除する
    .pipe pathSearch(paths.sp.dest, 'templates').on 'end', (cb) ->
      if i == jsonDataLength
        pathArray.unshift('!' + paths.sp.dest + 'index.html')
        pathArray.unshift(paths.sp.dest + '**/*.html')
      return
  done()

# sass compile process sp
cssSP = ->
  g.src paths.sp.css.sass, { sourcemaps: isSourcemap }
  .pipe $.plumber(plumberConfig)
  # gulp-header を使用して JSON ファイルを sass 変数に読み込む
  .pipe $.header(
    '$BASE_SITE_URL: "' + appConfig.BASE_SITE_URL + '";\n' +
    '$SITE_URL: "' + appConfig.APP_SITE_URL + '";\n' +
    '$SITE_NAME: "' + appConfig.SITE_NAME + '";\n' +
    '$AUTHOR: "' + appConfig.AUTHOR + '";\n' +
    '$MODIFIER: "' + appConfig.MODIFIER + '";\n' +
    '$UPDATE: "' + appConfig.UPDATE + '";\n' +
    '$TIMESTAMP: "?v=' + appConfig.TIMESTAMP + '";\n'
  )
  .pipe $.sass({
    outputStyle: 'expanded'
  }).on('error', $.sass.logError) # エラーでも止めない
  # postcss で画像サイズを取得し変換する
  .pipe $.postcss([
    require('postcss-assets')(
      basePath: paths.pc.dest # 公開フォルダのパス
      loadPaths: [paths.common.img.postcss, paths.sp.img.postcss] # basePath からみた images フォルダの位置
      relative: if not appConfig.ABSOLUTE_PATH then paths.sp.css.postcss # basePath と対になる css フォルダの位置
    )
    require('css-mqpacker')
    require('postcss-sorting')(
      require '../src/postcss-sorting.json' # 並び順の設定ファイル
    )
  ]).on('error', $.util.log) # エラーでも止めない
  .pipe $.autoprefixer overrideBrowserslist: ['> 0%']
  .pipe $.concat paths.sp.css.concat
  .pipe $.if isProduction, $.cleanCss({compatibility: 'ie8'})
  .pipe $.if isProduction, $.header(commentsCss, pkg: appConfig, filename: paths.sp.css.concat)
  .pipe g.dest paths.sp.css.dest, if not isProduction then { sourcemaps: isSourcemapOutput }
  # CSS を stream オプションでリアルタイムに反映
  .pipe bs.stream()
  # sourcemaps を本番ビルド時に削除する
  .pipe $.if isProduction, pathSearch(paths.sp.css.dest, 'css').on 'end', (cb) ->
    pathArray.unshift(paths.sp.css.dest + '**/*.map')
    return

# coffee compile process sp
coffeeSP = ->
  g.src([paths.sp.js.plugin, paths.sp.js.javascript, paths.sp.js.coffee])
  .pipe $.plumber(plumberConfig)
  .pipe webpackStream require('./webpack.config.sp.coffee'), webpack
  .pipe $.if isProduction, $.header(commentsJs, pkg: appConfig, filename: 'メインスクリプト')
  .pipe g.dest paths.sp.js.dest
  # JS を stream オプションでリアルタイムに反映
  .pipe bs.stream()
  # sourcemaps を本番ビルド時に削除する
  .pipe $.if isProduction, pathSearch(paths.sp.js.dest, 'js').on 'end', (cb) ->
    pathArray.unshift(paths.sp.js.dest + '**/*.map')
    return

# img check sp
imgCheckSP = ->
  g.src paths.sp.img.src
  .pipe $.plumber(plumberConfig)
  # src フォルダに存在しないファイルを htdocs から削除する
  .pipe pathSearch(rootDir.src + '/sp/images/', 'images').on 'end', (cb) ->
    pathArray.unshift(paths.sp.img.dest + '**/*.*')
    return

# img optimize sp
imgCompileSP = ->
  g.src paths.sp.img.src
  .pipe $.plumber(plumberConfig)
  # 画像に変更がない場合、出力しない
  .pipe $.changed(paths.sp.img.dest, { hasChanged: $.changed.compareContents })
  # .pipe $.imagemin()
  .pipe g.dest paths.sp.img.dest

# build sp
buildSP = (done) ->
  g.series 'lib', 'coffee', 'img', 'coffee-sp', 'img-sp', 'ect-sp', 'css-sp', 'remove-files', 'import'
  done()

#------------------------------------------------------
# Other Settings
# その他設定
#------------------------------------------------------

# remove files
removeFiles = (cb) ->
  del pathArray, cb

# clean
clean = (cb) ->
  if appConfig.RESPONSIVE_TEMPLATE
    rimraf paths.rp.dest, cb
  else
    rimraf paths.pc.dest, cb

# clean sp
cleanSP = (cb) ->
  rimraf paths.sp.dest, cb

# clean temp
cleanTemp = (cb) ->
  rimraf paths.archive.temp, cb

# clean archive
cleanArchive = (cb) ->
  rimraf paths.archive.dest, cb

#------------------------------------------------------
# Differential data extraction
# 差分データ抽出
#------------------------------------------------------

# temp process
tempData = ->
  g.src paths.archive.src
  .pipe $.plumber(plumberConfig)
  # htdocs を temp にコピー
  .pipe g.dest paths.archive.temp

# export process
exportData = ->
  date = new Date
  y = date.getFullYear()
  mon = date.getMonth() + 1
  d = date.getDate()
  h = date.getHours()
  m = date.getMinutes()
  s = date.getSeconds()
  g.src paths.archive.src
  .pipe $.plumber(plumberConfig)
  # Gulp 4 になりディレクトリが空の時にエラーが発生していたのを修正
  .pipe $.if(((f) ->
    !f.isDirectory()
  ), $.changed(paths.archive.temp, hasChanged: $.changed.compareContents))
  # 全ファイルをコピーするが、空フォルダは出力しない
  .pipe $.ignore.include({ isFile: true })
  # htdocs と temp を比較し htdocs に変更があれば差分データを zip に圧縮して出力
  .pipe $.zip 'archives_' + y + '-' + mon + '-' + d + '-' + h + '-' + m + '-' + s + '.zip'
  .pipe $.size(
    title: 'Saved'
    pretty: true
    showFiles: true
    showTotal: false
  )
  .pipe g.dest paths.archive.dest

#------------------------------------------------------
# Local server settings
# ローカルサーバー設定
#------------------------------------------------------

# browserSync
browserSync = ->
  bs.init null, {
    server:
      baseDir: rootDir.htdocs,
      middleware: [
        ssi({
          baseDir: path.join(__dirname, '../' + rootDir.htdocs),
          ext: '.html'
        })
      ]
    reloadDelay: 120
    notify: false
    ghostMode: false
    logPrefix: appConfig.SITE_NAME
    logFileChanges: false
    startPath: appConfig.CURRENT_DIR
  }, (err, bs) ->
    # API サーバー起動のログを出力
    if appConfig.API_SERVER
      baseURL = bs.getOption 'urls'
      localURL = url.parse baseURL.get 'local', false
      externalURL = url.parse baseURL.get 'external', false
      console.log '[\u001b[32mAPI Mock Server\u001b[0m] \u001b[1mAccess URLs: \u001b[0m'
      console.log ' \u001b[2m---------------------------------------\u001b[0m'
      console.log '       Local: \u001b[35m' + localURL.protocol + '//' + localURL.hostname + ':' + paths.api.port + paths.api.dest + '/db\u001b[0m'
      console.log '    External: \u001b[35m' + externalURL.protocol + '//' + externalURL.hostname + ':' + paths.api.port + paths.api.dest + '/db\u001b[0m'
      console.log ' \u001b[2m---------------------------------------\u001b[0m'
      console.log '[\u001b[32mAPI Mock Server\u001b[0m] Serving files from: \u001b[35msrc' + paths.api.dest + '\u001b[0m'
    return

#------------------------------------------------------
# Monitoring task
# 監視タスク
#------------------------------------------------------

# json-server watch & refresh
api = ->
  g.src paths.api.watch
  .pipe apiServer.pipe()

apiWatch = ->
  g.watch paths.api.watch, g.task('api') # json ファイルが変更または追加されたらビルド出力

# watch
watch = ->
  g.watch paths.common.import.json, g.task('import')
  g.watch [paths.common.js.plugin, paths.common.js.javascript, paths.common.js.coffee], g.task('coffee')
  g.watch paths.common.img.src, g.task('img') # img ファイルが変更または追加されたらビルド出力

# watch rp
watchRP = ->
  g.watch [paths.rp.ect.watch, paths.rp.ect.json], g.task('ect-rp')
  g.watch paths.rp.css.watch, g.task('css-rp')
  g.watch [paths.rp.js.plugin, paths.rp.js.javascript, paths.rp.js.coffee], g.task('coffee-rp')
  g.watch paths.rp.img.src, g.task('img-rp') # img ファイルが変更または追加されたらビルド出力

# watch pc
watchPC = ->
  g.watch [paths.pc.ect.watch, paths.pc.ect.json], g.task('ect-pc')
  g.watch paths.pc.css.watch, g.task('css-pc')
  g.watch [paths.pc.js.plugin, paths.pc.js.javascript, paths.pc.js.coffee], g.task('coffee-pc')
  g.watch paths.pc.img.src, g.task('img-pc') # img ファイルが変更または追加されたらビルド出力

# watch sp
watchSP = ->
  g.watch [paths.sp.ect.watch, paths.sp.ect.json], g.task('ect-sp')
  g.watch paths.sp.css.watch, g.task('css-sp')
  g.watch [paths.sp.js.plugin, paths.sp.js.javascript, paths.sp.js.coffee], g.task('coffee-sp')
  g.watch paths.sp.img.src, g.task('img-sp') # img ファイルが変更または追加されたらビルド出力

#------------------------------------------------------
# Declaring Each Task
# 各タスクの宣言
#------------------------------------------------------

# Common Task
exports.importData = importData
exports.libCopy = libCopy
exports.coffeeCompile = coffeeCompile
exports.imgCheck = imgCheck
exports.imgCompile = imgCompile

# Responsive Task
exports.ectRP = ectRP
exports.cssRP = cssRP
exports.coffeeRP = coffeeRP
exports.imgCheckRP = imgCheckRP
exports.imgCompileRP = imgCompileRP
exports.buildRP = buildRP

# PC Task
exports.ectPC = ectPC
exports.cssPC = cssPC
exports.coffeePC = coffeePC
exports.imgCheckPC = imgCheckPC
exports.imgCompilePC = imgCompilePC
exports.buildPC = buildPC

# SP Task
exports.ectSP = ectSP
exports.cssSP = cssSP
exports.coffeeSP = coffeeSP
exports.imgCheckSP = imgCheckSP
exports.imgCompileSP = imgCompileSP
exports.buildSP = buildSP

# Other Task
exports.removeFiles = removeFiles
exports.clean = clean
exports.cleanSP = cleanSP
exports.cleanTemp = cleanTemp
exports.cleanArchive = cleanArchive

# Differential Task
exports.tempData = tempData
exports.exportData = exportData

# Local server Task
exports.browserSync = browserSync

# Monitoring Task
exports.api = api
exports.apiWatch = apiWatch
exports.watch = watch
exports.watchRP = watchRP
exports.watchPC = watchPC
exports.watchSP = watchSP

#------------------------------------------------------
# Installation of each task
# 各タスクの設定
#------------------------------------------------------

# Common Task
g.task 'import', importData
g.task 'lib', libCopy
g.task 'coffee', coffeeCompile
g.task 'img', g.series(imgCheck, imgCompile)

# Responsive Task
g.task 'ect-rp', ectRP
g.task 'css-rp', cssRP
g.task 'coffee-rp', coffeeRP
g.task 'img-rp', g.series(imgCheckRP, imgCompileRP)
g.task 'build-rp', buildRP

# PC Task
g.task 'ect-pc', ectPC
g.task 'css-pc', cssPC
g.task 'coffee-pc', coffeePC
g.task 'img-pc', g.series(imgCheckPC, imgCompilePC)
g.task 'build-pc', buildPC

# SP Task
g.task 'ect-sp', ectSP
g.task 'css-sp', cssSP
g.task 'coffee-sp', coffeeSP
g.task 'img-sp', g.series(imgCheckSP, imgCompileSP)
g.task 'build-sp', buildSP

# Other Task
g.task 'remove-files', removeFiles
g.task 'clean', clean
g.task 'clean-sp', cleanSP
g.task 'clean-temp', cleanTemp
g.task 'clean-archive', g.series(cleanTemp, cleanArchive)

# Differential Task
g.task 'temp', tempData
g.task 'export', exportData
if appConfig.RESPONSIVE_TEMPLATE
  g.task 'diff', g.series 'clean', 'clean-temp', 'import', 'lib', 'coffee', 'img', 'ect-rp', 'css-rp', 'coffee-rp', 'img-rp', 'temp'
else
  g.task 'diff', g.series 'clean', 'clean-temp', 'import', 'lib', 'coffee', 'img', 'ect-pc', 'css-pc', 'coffee-pc', 'img-pc', 'ect-sp', 'css-sp', 'coffee-sp', 'img-sp', 'temp'

# Local server Task
g.task 'bs', browserSync
if appConfig.API_SERVER
  apiServer = jsonServer.create {
    port: paths.api.port,
    baseUrl: paths.api.dest,
    static: paths.api.src,
    verbosity: {
      level: "error",
      urlTracing: false
    }
  }

# Monitoring Task
g.task 'api', api
g.task 'watch-api', g.series(api, apiWatch)
g.task 'watch', watch
g.task 'watch-rp', watchRP
g.task 'watch-pc', watchPC
g.task 'watch-sp', watchSP

# Default task
if appConfig.RESPONSIVE_TEMPLATE
  # build
  g.task 'build', g.series('lib', 'coffee', 'img', 'coffee-rp', 'img-rp', 'ect-rp', 'css-rp', 'remove-files', 'import')
  # api
  if appConfig.API_SERVER
   g.task 'default', g.parallel('bs', 'watch-rp', 'watch', 'watch-api')
  else
   g.task 'default', g.parallel('bs', 'watch-rp', 'watch')
else
  # build
  g.task 'build', g.series('lib', 'coffee', 'coffee-pc', 'img-pc', 'coffee-sp', 'img-sp', 'img', 'ect-pc', 'css-pc', 'ect-sp', 'css-sp', 'remove-files', 'import')
  # api
  if appConfig.API_SERVER
    g.task 'default', g.parallel('bs', 'watch-pc', 'watch-sp', 'watch', 'watch-api')
  else
    g.task 'default', g.parallel('bs', 'watch-pc', 'watch-sp', 'watch')