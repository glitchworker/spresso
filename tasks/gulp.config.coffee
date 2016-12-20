#------------------------------------------------------
# Load module
# モジュール読み込み
#------------------------------------------------------

path = require 'path' # パス解析
g = require 'gulp' # Gulp 本体
$ = do require 'gulp-load-plugins' # package.json からプラグインを自動で読み込む
fs = require 'fs' # ファイルやディレクトリの操作

runSequence = require 'run-sequence' # タスクの並列 / 直列処理
rimraf = require 'rimraf' # 単一ファイル / ディレクトリ削除
del = require 'del' # 複数ファイル / ディレクトリ削除
minimist = require 'minimist' # Gulp で引数を解析
eventStream = require 'event-stream' # Gulp のイベントを取得する

bs = require('browser-sync').create() # Web サーバー作成
ssi = require 'browsersync-ssi' # SSI を有効化

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

isProduction = if options.env == 'production' then true else false

if isProduction
  APP_SITE_URL = appConfig.PROD_SITE_URL
else
  APP_SITE_URL = appConfig.DEV_SITE_URL

#------------------------------------------------------
# Additional settings of appConfig
# appConfig の追加設定
#------------------------------------------------------

appConfig.UPDATE = update # app.config.json に UPDATE 項目を追加
appConfig.TIMESTAMP = timestamp # app.config.json に TIMESTAMP 項目を追加
appConfig.APP_SITE_URL = APP_SITE_URL # app.config.json に APP_SITE_URL 項目を追加

#------------------------------------------------------
# Path Settings
# パス設定
#------------------------------------------------------

rootDir =
  src: 'src'
  htdocs: 'htdocs'
  archive: 'archives'
  temp: 'temp'

paths =
  common:
    js:
      plugin: rootDir.src + '/common/scripts/plugin/**/*.js'
      javascript: rootDir.src + '/common/scripts/javascript/**/*.js'
      coffee: rootDir.src + '/common/scripts/coffee/**/*.coffee'
      dest: rootDir.htdocs + '/assets/common/js/'
    img:
      src: rootDir.src + '/common/images/**/*.*'
      dest: rootDir.htdocs + '/assets/common/images/'
    libcopy:
      lib: rootDir.src + '/common/scripts/lib/**/*.js'
      dest: rootDir.htdocs + '/assets/common/js/lib/'
    import:
      json: rootDir.src + '/import/data.json'
  pc:
    dest: rootDir.htdocs + '/'
    ect:
      json: rootDir.src + '/pc/templates/pages.json'
      watch: rootDir.src + '/pc/templates/**/*.ect'
    css:
      concat: 'app.css'
      sass: rootDir.src + '/pc/stylesheets/app.scss'
      watch: rootDir.src + '/pc/stylesheets/**/*.scss'
      dest: rootDir.htdocs + '/assets/pc/css/'
    js:
      plugin: rootDir.src + '/pc/scripts/plugin/**/*.js'
      javascript: rootDir.src + '/pc/scripts/javascript/**/*.js'
      coffee: rootDir.src + '/pc/scripts/coffee/**/*.coffee'
      dest: rootDir.htdocs + '/assets/pc/js/'
    img:
      src: rootDir.src + '/pc/images/**/*.*'
      dest: rootDir.htdocs + '/assets/pc/images/'
  sp:
    dest: rootDir.htdocs + '/sp/'
    ect:
      json: rootDir.src + '/sp/templates/pages.json'
      watch: rootDir.src + '/sp/templates/**/*.ect'
    css:
      concat: 'app.css'
      sass: rootDir.src + '/sp/stylesheets/app.scss'
      watch: rootDir.src + '/sp/stylesheets/**/*.scss'
      dest: rootDir.htdocs + '/assets/sp/css/'
    js:
      plugin: rootDir.src + '/sp/scripts/plugin/**/*.js'
      javascript: rootDir.src + '/sp/scripts/javascript/**/*.js'
      coffee: rootDir.src + '/sp/scripts/coffee/**/*.coffee'
      dest: rootDir.htdocs + '/assets/sp/js/'
    img:
      src: rootDir.src + '/sp/images/**/*.*'
      dest: rootDir.htdocs + '/assets/sp/images/'
  archive:
    src: rootDir.htdocs + '/**/*'
    temp: rootDir.temp + '/'
    dest: rootDir.archive + '/'

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
  ' * @link <%= pkg.PROD_SITE_URL %>'
  ' * --------------------'
  ' */'
  ''
].join('\n')

#------------------------------------------------------
# Get filepath Settings
# ファイルパスを取得
#------------------------------------------------------

# path search process
pathArray = []
pathSearch = (dir, dirName) ->
  eventStream.map (file, done) ->
    filePath = $.slash(file.path)
    fileDir = filePath.match(dir + '.*')[0]
    if dirName == 'templates'
      fileReplace = fileDir.replace(rootDir.src + '/', paths.pc.dest).replace('/pc', '').replace('/templates', '')
    else if dirName == 'images'
      fileReplace = fileDir.replace(rootDir.src + '/', paths.pc.dest + 'assets/')
    else if dirName == 'js' or dirName == 'css'
      fileReplace = fileDir
    pathArray.push '!' + fileReplace
    done()
    return

#------------------------------------------------------
# Common Settings
# 共通設定
#------------------------------------------------------

# data import process
g.task 'import', ->
  jsonData = JSON.parse fs.readFileSync(paths.common.import.json)
  jsonData.forEach (page, i) ->
    if page.type == 'dir'
      g.src rootDir.src + '/import/' + page.data + '/**/*'
      .pipe $.plumber()
      .pipe $.changed(page.output)
      .pipe g.dest rootDir.htdocs + '/' + page.output
    else
      g.src rootDir.src + '/import/' + page.data
      .pipe $.plumber()
      .pipe $.changed(page.output)
      .pipe g.dest rootDir.htdocs + '/' + page.output

# lib copy process
g.task 'libcopy', ->
  g.src paths.common.libcopy.lib
  .pipe $.changed(paths.common.libcopy.dest)
  .pipe g.dest paths.common.libcopy.dest

# coffee compile process
g.task 'coffee', ->
  pathArray = []
  g.src([paths.common.js.plugin, paths.common.js.javascript, paths.common.js.coffee])
  .pipe $.plumber()
  .pipe $.webpack require './webpack.config.common.coffee'
  .pipe $.if isProduction, $.header(commentsJs, pkg: appConfig, filename: '共通スクリプト')
  .pipe g.dest paths.common.js.dest
  # JS を stream オプションでリアルタイムに反映
  .pipe bs.stream()
  # sourcemaps を本番ビルド時に削除する
  .pipe $.if isProduction, pathSearch(paths.common.js.dest, 'js').on 'end', (cb) ->
    pathArray.unshift(paths.common.js.dest + '**/*.map')
    del pathArray, cb
    return

# img file check
g.task 'img-check', ->
  pathArray = []
  return g.src paths.common.img.src
  .pipe $.plumber()
  # src フォルダに存在しないファイルを htdocs から削除する
  .pipe pathSearch(rootDir.src + '/common/images/', 'images').on 'end', (cb) ->
    pathArray.unshift(paths.common.img.dest + '**/*.*')
    del pathArray, cb
    return

# img optimize
g.task 'img', ['img-check'], ->
  g.src paths.common.img.src
  .pipe $.plumber()
  # 画像に変更がない場合、出力しない
  .pipe $.changed(paths.common.img.dest)
  .pipe $.imagemin()
  .pipe g.dest paths.common.img.dest

# build
g.task 'build', ->
  return runSequence 'libcopy', 'coffee', 'img', 'ect-pc', 'css-pc', 'coffee-pc', 'img-pc', 'ect-sp', 'css-sp', 'coffee-sp', 'img-sp'

#------------------------------------------------------
# Setting for PC
# PC 向け設定
#------------------------------------------------------

# ect json process pc
g.task 'ect-pc', ->
  pathArray = []
  jsonData = JSON.parse fs.readFileSync(paths.pc.ect.json)
  jsonDataLength = Object.keys(jsonData).length - 1
  jsonData.forEach (page, i) ->
    g.src rootDir.src + '/pc/templates/' + page.template + '.ect'
    .pipe $.plumber()
    # ect で JSON ファイルを変数に読み込む
    .pipe $.data (file)->
      staticData = page
      staticData.SITE_URL = APP_SITE_URL
      staticData.SITE_NAME = appConfig.SITE_NAME
      # 'index.html' を含むファイルパスを '/' に置き換え、含まない場合はファイルパスを出す
      if staticData.path_filename.indexOf('index.html') != -1
        if staticData.template == 'index'
          staticData.REDIRECT_PATH = staticData.path + 'sp/'
        else
          staticData.REDIRECT_PATH = staticData.path + 'sp/' + staticData.template + '/'
      else
        staticData.REDIRECT_PATH = staticData.path + 'sp/' + staticData.path_filename
      return staticData
    .pipe $.ect(data: page)
    # pages.json に記述された 'path_filename' で決めたパスに出力
    .pipe $.rename page.path_filename
    .pipe g.dest paths.pc.dest
    # html を stream オプションでリアルタイムに反映
    .pipe bs.stream()
    # src フォルダに存在しないファイルを htdocs から削除する
    .pipe pathSearch(paths.pc.dest, 'templates').on 'end', (cb) ->
      if i == jsonDataLength
        pathArray.unshift('!'+paths.pc.dest + 'index.html')
        pathArray.unshift('!'+paths.sp.dest + '**/*.html')
        pathArray.unshift(paths.pc.dest + '**/*.html')
        del pathArray, cb
      return

# sass compile process pc
g.task 'css-pc', ->
  pathArray = []
  g.src paths.pc.css.sass
  .pipe $.plumber()
  .pipe $.if not isProduction, $.sourcemaps.init()
  # sass で JSON ファイルを変数に読み込む
  .pipe $.sass({
    outputStyle: 'expanded'
    functions:
      'getJson($path)': require './script/sassGetJson'
  }).on('error', $.sass.logError) # エラーでも止めない
  .pipe $.autoprefixer autoprefixer: '> 5%'
  .pipe $.concat paths.pc.css.concat
  .pipe $.if isProduction, $.minifyCss({advanced:false})
  .pipe $.if isProduction, $.header(commentsCss, pkg: appConfig, filename: paths.pc.css.concat)
  .pipe $.if not isProduction, $.sourcemaps.write('./')
  .pipe g.dest paths.pc.css.dest
  # CSS を stream オプションでリアルタイムに反映
  .pipe bs.stream()
  # sourcemaps を本番ビルド時に削除する
  .pipe $.if isProduction, pathSearch(paths.pc.css.dest, 'css').on 'end', (cb) ->
    pathArray.unshift(paths.pc.css.dest + '**/*.map')
    del pathArray, cb
    return

# coffee compile process pc
g.task 'coffee-pc', ->
  pathArray = []
  g.src([paths.pc.js.plugin, paths.pc.js.javascript, paths.pc.js.coffee])
  .pipe $.plumber()
  .pipe $.webpack require './webpack.config.pc.coffee'
  .pipe $.if isProduction, $.header(commentsJs, pkg: appConfig, filename: 'メインスクリプト')
  .pipe g.dest paths.pc.js.dest
  # JS を stream オプションでリアルタイムに反映
  .pipe bs.stream()
  # sourcemaps を本番ビルド時に削除する
  .pipe $.if isProduction, pathSearch(paths.pc.js.dest, 'js').on 'end', (cb) ->
    pathArray.unshift(paths.pc.js.dest + '**/*.map')
    del pathArray, cb
    return

# img check pc
g.task 'img-pc-check', ->
  pathArray = []
  return g.src paths.pc.img.src
  .pipe $.plumber()
  # src フォルダに存在しないファイルを htdocs から削除する
  .pipe pathSearch(rootDir.src + '/pc/images/', 'images').on 'end', (cb) ->
    pathArray.unshift(paths.pc.img.dest + '**/*.*')
    del pathArray, cb
    return

# img optimize pc
g.task 'img-pc', ['img-pc-check'], ->
  g.src paths.pc.img.src
  .pipe $.plumber()
  # 画像に変更がない場合、出力しない
  .pipe $.changed(paths.pc.img.dest)
  .pipe $.imagemin()
  .pipe g.dest paths.pc.img.dest

# build pc
g.task 'build-pc', ->
  return runSequence 'libcopy', 'coffee', 'img', 'ect-pc', 'css-pc', 'coffee-pc', 'img-pc'

#------------------------------------------------------
# Setting for SP
# SP 向け設定
#------------------------------------------------------

# ect json process sp
g.task 'ect-sp', ->
  pathArray = []
  jsonData = JSON.parse fs.readFileSync(paths.sp.ect.json)
  jsonDataLength = Object.keys(jsonData).length - 1
  jsonData.forEach (page, i) ->
    g.src rootDir.src + '/sp/templates/' + page.template + '.ect'
    .pipe $.plumber()
    # ect で JSON ファイルを変数に読み込む
    .pipe $.data (file)->
      staticData = page
      staticData.SITE_URL = APP_SITE_URL
      staticData.SITE_NAME = appConfig.SITE_NAME
      # 'index.html' を含むファイルパスを '/' に置き換え、含まない場合はファイルパスを出す
      if staticData.path_filename.indexOf('index.html') != -1
        if staticData.template == 'index'
          staticData.REDIRECT_PATH = staticData.path
        else
          staticData.REDIRECT_PATH = staticData.path + staticData.template + '/'
      else
        staticData.REDIRECT_PATH = staticData.path + staticData.path_filename
      return staticData
    .pipe $.ect(data: page)
    # pages.json に記述された 'path_filename' で決めたパスに出力
    .pipe $.rename page.path_filename
    .pipe g.dest paths.sp.dest
    # html を stream オプションでリアルタイムに反映
    .pipe bs.stream()
    # src フォルダに存在しないファイルを htdocs から削除する
    .pipe pathSearch(paths.sp.dest, 'templates').on 'end', (cb) ->
      if i == jsonDataLength
        pathArray.unshift('!'+paths.sp.dest + 'index.html')
        pathArray.unshift(paths.sp.dest + '**/*.html')
        del pathArray, cb
      return

# sass compile process sp
g.task 'css-sp', ->
  pathArray = []
  g.src paths.sp.css.sass
  .pipe $.plumber()
  .pipe $.if not isProduction, $.sourcemaps.init()
  # sass で JSON ファイルを変数に読み込む
  .pipe $.sass({
    outputStyle: 'expanded'
    functions:
      'getJson($path)': require './script/sassGetJson'
  }).on('error', $.sass.logError) # エラーでも止めない
  .pipe $.autoprefixer autoprefixer: '> 5%'
  .pipe $.concat paths.sp.css.concat
  .pipe $.if isProduction, $.minifyCss({advanced:false})
  .pipe $.if isProduction, $.header(commentsCss, pkg: appConfig, filename: paths.sp.css.concat)
  .pipe $.if not isProduction, $.sourcemaps.write('./')
  .pipe g.dest paths.sp.css.dest
  # CSS を stream オプションでリアルタイムに反映
  .pipe bs.stream()
  # sourcemaps を本番ビルド時に削除する
  .pipe $.if isProduction, pathSearch(paths.sp.css.dest, 'css').on 'end', (cb) ->
    pathArray.unshift(paths.sp.css.dest + '**/*.map')
    del pathArray, cb
    return

# coffee compile process sp
g.task 'coffee-sp', ->
  pathArray = []
  g.src([paths.sp.js.plugin, paths.sp.js.javascript, paths.sp.js.coffee])
  .pipe $.plumber()
  .pipe $.webpack require './webpack.config.sp.coffee'
  .pipe $.if isProduction, $.header(commentsJs, pkg: appConfig, filename: 'メインスクリプト')
  .pipe g.dest paths.sp.js.dest
  # JS を stream オプションでリアルタイムに反映
  .pipe bs.stream()
  # sourcemaps を本番ビルド時に削除する
  .pipe $.if isProduction, pathSearch(paths.sp.js.dest, 'js').on 'end', (cb) ->
    pathArray.unshift(paths.sp.js.dest + '**/*.map')
    del pathArray, cb
    return

# img check sp
g.task 'img-sp-check', ->
  pathArray = []
  return g.src paths.sp.img.src
  .pipe $.plumber()
  # src フォルダに存在しないファイルを htdocs から削除する
  .pipe pathSearch(rootDir.src + '/sp/images/', 'images').on 'end', (cb) ->
    pathArray.unshift(paths.sp.img.dest + '**/*.*')
    del pathArray, cb
    return

# img optimize sp
g.task 'img-sp', ['img-sp-check'], ->
  g.src paths.sp.img.src
  .pipe $.plumber()
  # 画像に変更がない場合、出力しない
  .pipe $.changed(paths.sp.img.dest)
  .pipe $.imagemin()
  .pipe g.dest paths.sp.img.dest

# build sp
g.task 'build-sp', ->
  return runSequence 'libcopy', 'coffee', 'img', 'ect-sp', 'css-sp', 'coffee-sp', 'img-sp'

#------------------------------------------------------
# Differential data extraction
# 差分データ抽出
#------------------------------------------------------

# diff process
g.task 'diff', ['clean', 'clean-temp'], ->
  runSequence 'libcopy', 'coffee', 'img', 'ect-pc', 'css-pc', 'coffee-pc', 'img-pc', 'ect-sp', 'css-sp', 'coffee-sp', 'img-sp', 'temp'

# temp process
g.task 'temp', ->
  g.src paths.archive.src
  .pipe $.plumber()
  # htdocs を temp にコピー
  .pipe g.dest paths.archive.temp

# export process
g.task 'export', ->
  date = new Date
  y = date.getFullYear()
  mon = date.getMonth() + 1
  d = date.getDate()
  h = date.getHours()
  m = date.getMinutes()
  s = date.getSeconds()
  g.src paths.archive.src
  .pipe $.plumber()
  .pipe $.changed(paths.archive.temp, { hasChanged: $.changed.compareSha1Digest })
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
# Other Settings
# その他設定
#------------------------------------------------------

# clean
g.task 'clean', (cb) ->
  return rimraf paths.pc.dest, cb

# clean sp
g.task 'clean-sp', (cb) ->
  return rimraf paths.sp.dest, cb

# clean temp
g.task 'clean-temp', (cb) ->
  return rimraf paths.archive.temp, cb

# clean archive
g.task 'clean-archive', ['clean-temp'], (cb) ->
  return rimraf paths.archive.dest, cb

# browserSync
g.task 'bs', ->
  bs.init(null, {
    server:
      baseDir: rootDir.htdocs,
      middleware: [
        ssi({
          baseDir: __dirname + '/' + rootDir.htdocs,
          ext: '.html'
        })
      ]
    reloadDelay: 120
    notify: false
    ghostMode: false
    logPrefix: appConfig.SITE_NAME
    logFileChanges: false
  })

# watch
g.task 'watch', ['bs'], ->
  g.watch [paths.common.js.plugin, paths.common.js.javascript, paths.common.js.coffee], ['coffee']
  $.watch paths.common.img.src, ->
    g.start 'img-check' # img ファイルが変更または追加されたらビルド出力

# watch pc
g.task 'watch-pc', ['bs'], ->
  g.watch [paths.pc.ect.watch, paths.pc.ect.json], ['ect-pc']
  g.watch paths.pc.css.watch, ['css-pc']
  g.watch [paths.pc.js.plugin, paths.pc.js.javascript, paths.pc.js.coffee], ['coffee-pc']
  $.watch paths.pc.img.src, ->
    g.start 'img-pc-check' # img ファイルが変更または追加されたらビルド出力

# watch sp
g.task 'watch-sp', ['bs'], ->
  g.watch [paths.sp.ect.watch, paths.sp.ect.json], ['ect-sp']
  g.watch paths.sp.css.watch, ['css-sp']
  g.watch [paths.sp.js.plugin, paths.sp.js.javascript, paths.sp.js.coffee], ['coffee-sp']
  $.watch paths.sp.img.src, ->
    g.start 'img-sp-check' # img ファイルが変更または追加されたらビルド出力

# default task
g.task 'default', ['bs', 'watch-pc', 'watch-sp', 'watch']