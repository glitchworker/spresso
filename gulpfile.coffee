#------------------------------------------------------
# Load dependencies module
# 依存モジュール読み込み
#------------------------------------------------------

path = require 'path' # パス解析
g = require 'gulp' # Gulp 本体
series = g.series # Gulp - 直列処理
parallel = g.parallel # Gulp - 並列処理
watch = g.watch # Gulp - ファイル監視
src = g.src # Gulp - ソース指定
dest = g.dest # Gulp - 出力先

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

appConfig = require './src/app.config.json' # サイト共通設定
update = do require './tasks/script/getTime' # 現在日時取得
timestamp = do require './tasks/script/getTimeStamp' # 現在タイムスタンプ取得
postCSSSortingConfig = './src/postcss-sorting.json' # PostCSS の ソート設定

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
      src rootDir.src + '/import/' + page.DATA + '/**/*', { allowEmpty: true }
      .pipe $.plumber(plumberConfig)
      .pipe $.changed(page.OUTPUT, { hasChanged: $.changed.compareContents })
      .pipe dest rootDir.htdocs + '/' + page.OUTPUT
    else
      src rootDir.src + '/import/' + page.DATA, { allowEmpty: true }
      .pipe $.plumber(plumberConfig)
      .pipe $.changed(page.OUTPUT, { hasChanged: $.changed.compareContents })
      .pipe dest rootDir.htdocs + '/' + page.OUTPUT
  done()

# lib copy process
libCopy = ->
  src paths.common.libCopy.lib
  .pipe $.changed(paths.common.libCopy.dest)
  .pipe dest paths.common.libCopy.dest

# coffee compile process
coffeeCompile = ->
  src([paths.common.js.plugin, paths.common.js.javascript, paths.common.js.coffee])
  .pipe $.plumber(plumberConfig)
  .pipe webpackStream require('./tasks/webpack.config.common.coffee'), webpack
  .pipe $.if isProduction, $.header(commentsJs, pkg: appConfig, filename: '共通スクリプト')
  .pipe dest paths.common.js.dest
  # JS を stream オプションでリアルタイムに反映
  .pipe bs.stream()
  # sourcemaps を本番ビルド時に削除する
  .pipe $.if isProduction, pathSearch(paths.common.js.dest, 'js').on 'end', (cb) ->
    pathArray.unshift(paths.common.js.dest + '**/*.map')
    return

# img file check
imgCheck = ->
  src paths.common.img.src
  .pipe $.plumber(plumberConfig)
  # src フォルダに存在しないファイルを htdocs から削除する
  .pipe pathSearch(rootDir.src + '/common/images/', 'images').on 'end', (cb) ->
    pathArray.unshift(paths.common.img.dest + '**/*.*')
    return

# img optimize
imgCompile = ->
  src paths.common.img.src
  .pipe $.plumber(plumberConfig)
  # 画像に変更がない場合、出力しない
  .pipe $.changed(paths.common.img.dest, { hasChanged: $.changed.compareContents })
  # .pipe $.imagemin()
  .pipe dest paths.common.img.dest

#------------------------------------------------------
# Setting for Responsive
# Responsive 向け設定
#------------------------------------------------------

# ect json process rp
ectRP = (done) ->
  jsonData = JSON.parse fs.readFileSync(paths.rp.ect.json)
  jsonDataLength = Object.keys(jsonData).length - 1
  jsonData.forEach (page, i) ->
    src rootDir.src + '/rp/templates/' + page.TEMPLATE_ECT + '.ect'
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
    .pipe dest paths.rp.dest
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
  src paths.rp.css.sass, { sourcemaps: isSourcemap }
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
      require postCSSSortingConfig # 並び順の設定ファイル
    )
  ]).on('error', $.util.log) # エラーでも止めない
  .pipe $.autoprefixer overrideBrowserslist: ['> 0%']
  .pipe $.concat paths.rp.css.concat
  .pipe $.if isProduction, $.cleanCss({compatibility: 'ie8'})
  .pipe $.if isProduction, $.header(commentsCss, pkg: appConfig, filename: paths.rp.css.concat)
  .pipe dest paths.rp.css.dest, if not isProduction then { sourcemaps: isSourcemapOutput }
  # CSS を stream オプションでリアルタイムに反映
  .pipe bs.stream()
  # sourcemaps を本番ビルド時に削除する
  .pipe $.if isProduction, pathSearch(paths.rp.css.dest, 'css').on 'end', (cb) ->
    pathArray.unshift(paths.rp.css.dest + '**/*.map')
    return

# coffee compile process rp
coffeeRP = ->
  src([paths.rp.js.plugin, paths.rp.js.javascript, paths.rp.js.coffee])
  .pipe $.plumber(plumberConfig)
  .pipe webpackStream require('./tasks/webpack.config.rp.coffee'), webpack
  .pipe $.if isProduction, $.header(commentsJs, pkg: appConfig, filename: 'メインスクリプト')
  .pipe dest paths.rp.js.dest
  # JS を stream オプションでリアルタイムに反映
  .pipe bs.stream()
  # sourcemaps を本番ビルド時に削除する
  .pipe $.if isProduction, pathSearch(paths.rp.js.dest, 'js').on 'end', (cb) ->
    pathArray.unshift(paths.rp.js.dest + '**/*.map')
    return

# img check rp
imgCheckRP = ->
  src paths.rp.img.src
  .pipe $.plumber(plumberConfig)
  # src フォルダに存在しないファイルを htdocs から削除する
  .pipe pathSearch(rootDir.src + '/rp/images/', 'images').on 'end', (cb) ->
    pathArray.unshift(paths.rp.img.dest + '**/*.*')
    return

# img optimize rp
imgCompileRP = ->
  src paths.rp.img.src
  .pipe $.plumber(plumberConfig)
  # 画像に変更がない場合、出力しない
  .pipe $.changed(paths.rp.img.dest, { hasChanged: $.changed.compareContents })
  # .pipe $.imagemin()
  .pipe dest paths.rp.img.dest

#------------------------------------------------------
# Setting for PC
# PC 向け設定
#------------------------------------------------------

# ect json process pc
ectPC = (done) ->
  jsonData = JSON.parse fs.readFileSync(paths.pc.ect.json)
  jsonDataLength = Object.keys(jsonData).length - 1
  jsonData.forEach (page, i) ->
    src rootDir.src + '/pc/templates/' + page.TEMPLATE_ECT + '.ect'
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
    .pipe dest paths.pc.dest
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
  src paths.pc.css.sass, { sourcemaps: isSourcemap }
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
      require postCSSSortingConfig # 並び順の設定ファイル
    )
  ]).on('error', $.util.log) # エラーでも止めない
  .pipe $.autoprefixer overrideBrowserslist: ['> 0%']
  .pipe $.concat paths.pc.css.concat
  .pipe $.if isProduction, $.cleanCss({compatibility: 'ie8'})
  .pipe $.if isProduction, $.header(commentsCss, pkg: appConfig, filename: paths.pc.css.concat)
  .pipe dest paths.pc.css.dest, if not isProduction then { sourcemaps: isSourcemapOutput }
  # CSS を stream オプションでリアルタイムに反映
  .pipe bs.stream()
  # sourcemaps を本番ビルド時に削除する
  .pipe $.if isProduction, pathSearch(paths.pc.css.dest, 'css').on 'end', (cb) ->
    pathArray.unshift(paths.pc.css.dest + '**/*.map')
    return

# coffee compile process pc
coffeePC = ->
  src([paths.pc.js.plugin, paths.pc.js.javascript, paths.pc.js.coffee])
  .pipe $.plumber(plumberConfig)
  .pipe webpackStream require('./tasks/webpack.config.pc.coffee'), webpack
  .pipe $.if isProduction, $.header(commentsJs, pkg: appConfig, filename: 'メインスクリプト')
  .pipe dest paths.pc.js.dest
  # JS を stream オプションでリアルタイムに反映
  .pipe bs.stream()
  # sourcemaps を本番ビルド時に削除する
  .pipe $.if isProduction, pathSearch(paths.pc.js.dest, 'js').on 'end', (cb) ->
    pathArray.unshift(paths.pc.js.dest + '**/*.map')
    return

# img check pc
imgCheckPC = ->
  src paths.pc.img.src
  .pipe $.plumber(plumberConfig)
  # src フォルダに存在しないファイルを htdocs から削除する
  .pipe pathSearch(rootDir.src + '/pc/images/', 'images').on 'end', (cb) ->
    pathArray.unshift(paths.pc.img.dest + '**/*.*')
    return

# img optimize pc
imgCompilePC = ->
  src paths.pc.img.src
  .pipe $.plumber(plumberConfig)
  # 画像に変更がない場合、出力しない
  .pipe $.changed(paths.pc.img.dest, { hasChanged: $.changed.compareContents })
  # .pipe $.imagemin()
  .pipe dest paths.pc.img.dest

#------------------------------------------------------
# Setting for SP
# SP 向け設定
#------------------------------------------------------

# ect json process sp
ectSP = (done) ->
  jsonData = JSON.parse fs.readFileSync(paths.sp.ect.json)
  jsonDataLength = Object.keys(jsonData).length - 1
  jsonData.forEach (page, i) ->
    src rootDir.src + '/sp/templates/' + page.TEMPLATE_ECT + '.ect'
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
    .pipe dest paths.sp.dest
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
  src paths.sp.css.sass, { sourcemaps: isSourcemap }
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
      require postCSSSortingConfig # 並び順の設定ファイル
    )
  ]).on('error', $.util.log) # エラーでも止めない
  .pipe $.autoprefixer overrideBrowserslist: ['> 0%']
  .pipe $.concat paths.sp.css.concat
  .pipe $.if isProduction, $.cleanCss({compatibility: 'ie8'})
  .pipe $.if isProduction, $.header(commentsCss, pkg: appConfig, filename: paths.sp.css.concat)
  .pipe dest paths.sp.css.dest, if not isProduction then { sourcemaps: isSourcemapOutput }
  # CSS を stream オプションでリアルタイムに反映
  .pipe bs.stream()
  # sourcemaps を本番ビルド時に削除する
  .pipe $.if isProduction, pathSearch(paths.sp.css.dest, 'css').on 'end', (cb) ->
    pathArray.unshift(paths.sp.css.dest + '**/*.map')
    return

# coffee compile process sp
coffeeSP = ->
  src([paths.sp.js.plugin, paths.sp.js.javascript, paths.sp.js.coffee])
  .pipe $.plumber(plumberConfig)
  .pipe webpackStream require('./tasks/webpack.config.sp.coffee'), webpack
  .pipe $.if isProduction, $.header(commentsJs, pkg: appConfig, filename: 'メインスクリプト')
  .pipe dest paths.sp.js.dest
  # JS を stream オプションでリアルタイムに反映
  .pipe bs.stream()
  # sourcemaps を本番ビルド時に削除する
  .pipe $.if isProduction, pathSearch(paths.sp.js.dest, 'js').on 'end', (cb) ->
    pathArray.unshift(paths.sp.js.dest + '**/*.map')
    return

# img check sp
imgCheckSP = ->
  src paths.sp.img.src
  .pipe $.plumber(plumberConfig)
  # src フォルダに存在しないファイルを htdocs から削除する
  .pipe pathSearch(rootDir.src + '/sp/images/', 'images').on 'end', (cb) ->
    pathArray.unshift(paths.sp.img.dest + '**/*.*')
    return

# img optimize sp
imgCompileSP = ->
  src paths.sp.img.src
  .pipe $.plumber(plumberConfig)
  # 画像に変更がない場合、出力しない
  .pipe $.changed(paths.sp.img.dest, { hasChanged: $.changed.compareContents })
  # .pipe $.imagemin()
  .pipe dest paths.sp.img.dest

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
  src paths.archive.src
  .pipe $.plumber(plumberConfig)
  # htdocs を temp にコピー
  .pipe dest paths.archive.temp

# export process
exportData = ->
  date = new Date
  y = date.getFullYear()
  mon = date.getMonth() + 1
  d = date.getDate()
  h = date.getHours()
  m = date.getMinutes()
  s = date.getSeconds()
  src paths.archive.src
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
  .pipe dest paths.archive.dest

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
# API server settings
# APIサーバー設定
#------------------------------------------------------

# API Server Init
apiServer = undefined
apiServerInit = ->
  apiServer = jsonServer.create {
    port: paths.api.port,
    baseUrl: paths.api.dest,
    static: paths.api.src,
    verbosity: {
      level: "error",
      urlTracing: false
    }
  }

api = ->
  src paths.api.watch
  .pipe apiServer.pipe()

#------------------------------------------------------
# Monitoring task
# 監視タスク
#------------------------------------------------------

# watch
watchCommon = ->
  watch paths.common.import.json, series importData
  watch [paths.common.js.plugin, paths.common.js.javascript, paths.common.js.coffee], series coffeeCompile
  watch paths.common.img.src, series imgCheck, imgCompile # img ファイルが変更または追加されたらビルド出力

# watch rp
watchRP = ->
  watch [paths.rp.ect.watch, paths.rp.ect.json], series ectRP
  watch paths.rp.css.watch, series cssRP
  watch [paths.rp.js.plugin, paths.rp.js.javascript, paths.rp.js.coffee], series coffeeRP
  watch paths.rp.img.src, series imgCheckRP, imgCompileRP # img ファイルが変更または追加されたらビルド出力

# watch pc
watchPC = ->
  watch [paths.pc.ect.watch, paths.pc.ect.json], series ectPC
  watch paths.pc.css.watch, series cssPC
  watch [paths.pc.js.plugin, paths.pc.js.javascript, paths.pc.js.coffee], series coffeePC
  watch paths.pc.img.src, series imgCheckPC, imgCompilePC # img ファイルが変更または追加されたらビルド出力

# watch sp
watchSP = ->
  watch [paths.sp.ect.watch, paths.sp.ect.json], series ectSP
  watch paths.sp.css.watch, series cssSP
  watch [paths.sp.js.plugin, paths.sp.js.javascript, paths.sp.js.coffee], series coffeeSP
  watch paths.sp.img.src, series imgCheckSP, imgCompileSP # img ファイルが変更または追加されたらビルド出力

# watch api
apiWatch = ->
  watch paths.api.watch, series api # json ファイルが変更または追加されたらビルド出力

#------------------------------------------------------
# Declaring Each Task
# 各タスクの宣言
#------------------------------------------------------

# Build Task - Responsive
exports.buildRP = series libCopy, coffeeCompile, imgCheck, imgCompile, coffeeRP, imgCheckRP, imgCompileRP, ectRP, cssRP, removeFiles, importData

# Build Task - PC
exports.buildPC = series libCopy, coffeeCompile, imgCheck, imgCompile, coffeePC, imgCheckPC, imgCompilePC, ectPC, cssPC, removeFiles, importData

# Build Task - SP
exports.buildSP = series libCopy, coffeeCompile, imgCheck, imgCompile, coffeeSP, imgCheckSP, imgCompileSP, ectSP, cssSP, removeFiles, importData

# Clean Task
exports.clean = clean
exports.cleanSP = cleanSP
exports.cleanArchive = series cleanTemp, cleanArchive

# Import / Export Task
exports.import = importData
exports.export = exportData

# Watch Task
exports.watchRP = watchRP
exports.watchPC = watchPC
exports.watchSP = watchSP

# Static / Responsive Switch
if appConfig.RESPONSIVE_TEMPLATE
  # All Build Task
  exports.build = series libCopy, coffeeCompile, imgCheck, imgCompile, coffeeRP, imgCheckRP, imgCompileRP, ectRP, cssRP, removeFiles, importData
  # diff Task
  exports.diff = series clean, cleanTemp, importData, libCopy, coffeeCompile, imgCheck, imgCompile, ectRP, cssRP, coffeeRP, imgCheckRP, imgCompileRP, tempData
  # Default Task
  if appConfig.API_SERVER
    # API Server
    exports.default = parallel browserSync, watchRP, watchCommon, apiServerInit, api, apiWatch
  else
    # Normal Server
    exports.default = parallel browserSync, watchRP, watchCommon
else
  # All Build Task
  exports.build = series libCopy, coffeeCompile, coffeePC, imgCheckPC, imgCompilePC, coffeeSP, imgCheckSP, imgCompileSP, imgCheck, imgCompile, ectPC, cssPC, ectSP, cssSP, removeFiles, importData
  # diff Task
  exports.diff = series clean, cleanTemp, importData, libCopy, coffeeCompile, imgCheck, imgCompile, ectPC, cssPC, coffeePC, imgCheckPC, imgCompilePC, ectSP, cssSP, coffeeSP, imgCheckSP, imgCompileSP, tempData
  # Default Task
  if appConfig.API_SERVER
    # API Server
    exports.default = parallel browserSync, watchPC, watchSP, watchCommon, apiServerInit, api, apiWatch
  else
    # Normal Server
    exports.default = parallel browserSync, watchPC, watchSP, watchCommon