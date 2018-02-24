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
appConfig.APP_SITE_URL = APP_SITE_URL + appConfig.CURRENT_DIR # app.config.json に APP_SITE_URL 項目を追加
appConfig.RESPONSIVE_TEMPLATE = String(appConfig.RESPONSIVE_TEMPLATE) # app.config.json の RESPONSIVE_TEMPLATE 項目を String 型に変換

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
      dest: rootDir.htdocs + '/assets/' + appConfig.CURRENT_DIR + 'common/js/'
    img:
      src: rootDir.src + '/common/images/**/*.*'
      postcss: 'assets/' + appConfig.CURRENT_DIR + 'common/images/'
      dest: rootDir.htdocs + '/assets/' + appConfig.CURRENT_DIR + 'common/images/'
    libcopy:
      lib: rootDir.src + '/common/scripts/lib/**/*.js'
      dest: rootDir.htdocs + '/assets/' + appConfig.CURRENT_DIR + 'common/js/lib/'
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
      postcss: 'assets/' + appConfig.CURRENT_DIR + 'rp/css/'
      dest: rootDir.htdocs + '/assets/' + appConfig.CURRENT_DIR + 'rp/css/'
    js:
      plugin: rootDir.src + '/rp/scripts/plugin/**/*.js'
      javascript: rootDir.src + '/rp/scripts/javascript/**/*.js'
      coffee: rootDir.src + '/rp/scripts/coffee/**/*.coffee'
      dest: rootDir.htdocs + '/assets/' + appConfig.CURRENT_DIR + 'rp/js/'
    img:
      src: rootDir.src + '/rp/images/**/*.*'
      postcss: 'assets/' + appConfig.CURRENT_DIR + 'rp/images/'
      dest: rootDir.htdocs + '/assets/' + appConfig.CURRENT_DIR + 'rp/images/'
  pc:
    dest: rootDir.htdocs + '/'
    ect:
      json: rootDir.src + '/pc/templates/pages.json'
      watch: rootDir.src + '/pc/templates/**/*.ect'
    css:
      concat: 'app.css'
      sass: rootDir.src + '/pc/stylesheets/app.scss'
      watch: rootDir.src + '/pc/stylesheets/**/*.scss'
      postcss: 'assets/' + appConfig.CURRENT_DIR + 'pc/css/'
      dest: rootDir.htdocs + '/assets/' + appConfig.CURRENT_DIR + 'pc/css/'
    js:
      plugin: rootDir.src + '/pc/scripts/plugin/**/*.js'
      javascript: rootDir.src + '/pc/scripts/javascript/**/*.js'
      coffee: rootDir.src + '/pc/scripts/coffee/**/*.coffee'
      dest: rootDir.htdocs + '/assets/' + appConfig.CURRENT_DIR + 'pc/js/'
    img:
      src: rootDir.src + '/pc/images/**/*.*'
      postcss: 'assets/' + appConfig.CURRENT_DIR + 'pc/images/'
      dest: rootDir.htdocs + '/assets/' + appConfig.CURRENT_DIR + 'pc/images/'
  sp:
    dest: rootDir.htdocs + '/sp/'
    ect:
      json: rootDir.src + '/sp/templates/pages.json'
      watch: rootDir.src + '/sp/templates/**/*.ect'
    css:
      concat: 'app.css'
      sass: rootDir.src + '/sp/stylesheets/app.scss'
      watch: rootDir.src + '/sp/stylesheets/**/*.scss'
      postcss: 'assets/sp/css/'
      dest: rootDir.htdocs + '/assets/' + appConfig.CURRENT_DIR + 'sp/css/'
    js:
      plugin: rootDir.src + '/sp/scripts/plugin/**/*.js'
      javascript: rootDir.src + '/sp/scripts/javascript/**/*.js'
      coffee: rootDir.src + '/sp/scripts/coffee/**/*.coffee'
      dest: rootDir.htdocs + '/assets/' + appConfig.CURRENT_DIR + 'sp/js/'
    img:
      src: rootDir.src + '/sp/images/**/*.*'
      postcss: 'assets/' + appConfig.CURRENT_DIR + 'sp/images/'
      dest: rootDir.htdocs + '/assets/' + appConfig.CURRENT_DIR + 'sp/images/'
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
      if appConfig.RESPONSIVE_TEMPLATE == 'true'
        fileReplace = fileDir.replace(rootDir.src + '/', paths.rp.dest).replace('/rp', '').replace('/templates', '')
      else
        fileReplace = fileDir.replace(rootDir.src + '/', paths.pc.dest).replace('/pc', '').replace('/templates', '')
    else if dirName == 'images'
      fileReplace = fileDir.replace(rootDir.src + '/', paths.pc.dest + 'assets/' + appConfig.CURRENT_DIR)
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
g.task 'import', ->
  jsonData = JSON.parse fs.readFileSync(paths.common.import.json)
  jsonData.forEach (page, i) ->
    if page.type == 'dir'
      g.src rootDir.src + '/import/' + page.data + '/**/*'
      .pipe $.plumber(plumberConfig)
      .pipe $.changed(page.output, { hasChanged: $.changed.compareSha1Digest })
      .pipe g.dest rootDir.htdocs + '/' + page.output
    else
      g.src rootDir.src + '/import/' + page.data
      .pipe $.plumber(plumberConfig)
      .pipe $.changed(page.output, { hasChanged: $.changed.compareSha1Digest })
      .pipe g.dest rootDir.htdocs + '/' + page.output

# lib copy process
g.task 'libcopy', ->
  g.src paths.common.libcopy.lib
  .pipe $.changed(paths.common.libcopy.dest)
  .pipe g.dest paths.common.libcopy.dest

# coffee compile process
g.task 'coffee', ->
  g.src([paths.common.js.plugin, paths.common.js.javascript, paths.common.js.coffee])
  .pipe $.plumber(plumberConfig)
  .pipe $.webpack require './webpack.config.common.coffee'
  .pipe $.if isProduction, $.header(commentsJs, pkg: appConfig, filename: '共通スクリプト')
  .pipe g.dest paths.common.js.dest
  # JS を stream オプションでリアルタイムに反映
  .pipe bs.stream()
  # sourcemaps を本番ビルド時に削除する
  .pipe $.if isProduction, pathSearch(paths.common.js.dest, 'js').on 'end', (cb) ->
    pathArray.unshift(paths.common.js.dest + '**/*.map')
    return

# img file check
g.task 'img-check', ->
  return g.src paths.common.img.src
  .pipe $.plumber(plumberConfig)
  # src フォルダに存在しないファイルを htdocs から削除する
  .pipe pathSearch(rootDir.src + '/common/images/', 'images').on 'end', (cb) ->
    pathArray.unshift(paths.common.img.dest + '**/*.*')
    return

# img optimize
g.task 'img', ['img-check'], ->
  g.src paths.common.img.src
  .pipe $.plumber(plumberConfig)
  # 画像に変更がない場合、出力しない
  .pipe $.changed(paths.common.img.dest, { hasChanged: $.changed.compareSha1Digest })
  # .pipe $.imagemin()
  .pipe g.dest paths.common.img.dest

# build
g.task 'build', ->
  if appConfig.RESPONSIVE_TEMPLATE == 'true'
    return runSequence 'import', 'libcopy', 'coffee', 'img', 'coffee-rp', 'img-rp', 'ect-rp', 'css-rp', 'remove-files'
  else
    return runSequence 'import', 'libcopy', 'coffee', 'coffee-pc', 'img-pc', 'coffee-sp', 'img-sp', 'img', 'ect-pc', 'css-pc', 'ect-sp', 'css-sp', 'remove-files'

#------------------------------------------------------
# Setting for Responsive
# Responsive 向け設定
#------------------------------------------------------

# ect json process rp
g.task 'ect-rp', ->
  jsonData = JSON.parse fs.readFileSync(paths.rp.ect.json)
  jsonDataLength = Object.keys(jsonData).length - 1
  jsonData.forEach (page, i) ->
    g.src rootDir.src + '/rp/templates/' + page.template + '.ect'
    .pipe $.plumber(plumberConfig)
    # ect で JSON ファイルを変数に読み込む
    .pipe $.data (file)->
      staticData = page
      staticData.RELATIVE_PATH = abspath2rel appConfig.CURRENT_DIR, '' + abspath2rel staticData.path_filename, ''
      staticData.SITE_URL = appConfig.APP_SITE_URL
      staticData.SITE_NAME = appConfig.SITE_NAME
      staticData.CURRENT_DIR = appConfig.CURRENT_DIR
      # 'index.html' を含まないファイルパスを出す
      staticData.FILE_PATH = staticData.path_filename.replace appConfig.CURRENT_DIR, ''
      staticData.FILE_PATH = staticData.FILE_PATH.replace 'index.html', ''
      return staticData
    .pipe $.ect(data: page)
    # pages.json に記述された 'path_filename' で決めたパスに出力
    .pipe $.rename appConfig.CURRENT_DIR + page.path_filename
    .pipe g.dest paths.rp.dest
    # html を stream オプションでリアルタイムに反映
    .pipe bs.stream()
    # src フォルダに存在しないファイルを htdocs から削除する
    .pipe pathSearch(paths.rp.dest, 'templates').on 'end', (cb) ->
      if i == jsonDataLength
        pathArray.unshift('!' + paths.rp.dest + 'index.html')
        pathArray.unshift(paths.rp.dest + '**/*.html')
      return

# sass compile process rp
g.task 'css-rp', ->
  g.src paths.rp.css.sass
  .pipe $.plumber(plumberConfig)
  .pipe $.if not isProduction, $.sourcemaps.init()
  # gulp-header を使用して JSON ファイルを sass 変数に読み込む
  .pipe $.header(
    '$SITE_URL: "' + appConfig.APP_SITE_URL + '";\n' +
    '$SITE_NAME: "' + appConfig.SITE_NAME + '";\n' +
    '$AUTHOR: "' + appConfig.AUTHOR + '";\n' +
    '$MODIFIER: "' + appConfig.MODIFIER + '";\n' +
    '$UPDATE: "' + appConfig.UPDATE + '";\n' +
    '$TIMESTAMP: "?v=' + appConfig.TIMESTAMP + '";\n'
  )
  .pipe $.sass({
    outputStyle: 'expanded'
    # functions:
    #   'getJson($path)': require './script/sassGetJson'
  }).on('error', $.sass.logError) # エラーでも止めない
  # postcss で画像サイズを取得し変換する
  .pipe $.postcss([
    require('postcss-assets')(
      loadPaths: [paths.common.img.postcss, paths.rp.img.postcss]
      basePath: paths.rp.dest
      relative: paths.rp.css.postcss
    )
    require('css-mqpacker')
    require('postcss-sorting')(
      require '../src/postcss-sorting.json' # 並び順の設定ファイル
    )
  ]).on('error', $.util.log) # エラーでも止めない
  .pipe $.autoprefixer browsers: ['> 0%']
  .pipe $.concat paths.rp.css.concat
  .pipe $.if isProduction, $.minifyCss({advanced:false})
  .pipe $.if isProduction, $.header(commentsCss, pkg: appConfig, filename: paths.rp.css.concat)
  .pipe $.if not isProduction, $.sourcemaps.write('./')
  .pipe g.dest paths.rp.css.dest
  # CSS を stream オプションでリアルタイムに反映
  .pipe bs.stream()
  # sourcemaps を本番ビルド時に削除する
  .pipe $.if isProduction, pathSearch(paths.rp.css.dest, 'css').on 'end', (cb) ->
    pathArray.unshift(paths.rp.css.dest + '**/*.map')
    return

# coffee compile process rp
g.task 'coffee-rp', ->
  g.src([paths.rp.js.plugin, paths.rp.js.javascript, paths.rp.js.coffee])
  .pipe $.plumber(plumberConfig)
  .pipe $.webpack require './webpack.config.rp.coffee'
  .pipe $.if isProduction, $.header(commentsJs, pkg: appConfig, filename: 'メインスクリプト')
  .pipe g.dest paths.rp.js.dest
  # JS を stream オプションでリアルタイムに反映
  .pipe bs.stream()
  # sourcemaps を本番ビルド時に削除する
  .pipe $.if isProduction, pathSearch(paths.rp.js.dest, 'js').on 'end', (cb) ->
    pathArray.unshift(paths.rp.js.dest + '**/*.map')
    return

# img check rp
g.task 'img-rp-check', ->
  return g.src paths.rp.img.src
  .pipe $.plumber(plumberConfig)
  # src フォルダに存在しないファイルを htdocs から削除する
  .pipe pathSearch(rootDir.src + '/rp/images/', 'images').on 'end', (cb) ->
    pathArray.unshift(paths.rp.img.dest + '**/*.*')
    return

# img optimize rp
g.task 'img-rp', ['img-rp-check'], ->
  g.src paths.rp.img.src
  .pipe $.plumber(plumberConfig)
  # 画像に変更がない場合、出力しない
  .pipe $.changed(paths.rp.img.dest, { hasChanged: $.changed.compareSha1Digest })
  # .pipe $.imagemin()
  .pipe g.dest paths.rp.img.dest

# build rp
g.task 'build-rp', ->
  return runSequence 'import', 'libcopy', 'coffee', 'img', 'coffee-rp', 'img-rp', 'ect-rp', 'css-rp', 'remove-files'

#------------------------------------------------------
# Setting for PC
# PC 向け設定
#------------------------------------------------------

# ect json process pc
g.task 'ect-pc', ->
  jsonData = JSON.parse fs.readFileSync(paths.pc.ect.json)
  jsonDataLength = Object.keys(jsonData).length - 1
  jsonData.forEach (page, i) ->
    g.src rootDir.src + '/pc/templates/' + page.template + '.ect'
    .pipe $.plumber(plumberConfig)
    # ect で JSON ファイルを変数に読み込む
    .pipe $.data (file)->
      staticData = page
      staticData.RELATIVE_PATH = abspath2rel appConfig.CURRENT_DIR, '' + abspath2rel staticData.path_filename, ''
      staticData.SITE_URL = appConfig.APP_SITE_URL
      staticData.SITE_NAME = appConfig.SITE_NAME
      staticData.CURRENT_DIR = appConfig.CURRENT_DIR
      # 'index.html' を含まないファイルパスを出す
      staticData.FILE_PATH = staticData.path_filename.replace appConfig.CURRENT_DIR, ''
      staticData.FILE_PATH = staticData.FILE_PATH.replace 'index.html', ''
      # 'index.html' を含まないリダイレクトパスを出す
      staticData.REDIRECT_PATH = staticData.RELATIVE_PATH + 'sp/' + appConfig.CURRENT_DIR + staticData.path_filename.replace 'index.html', ''
      return staticData
    .pipe $.ect(data: page)
    # pages.json に記述された 'path_filename' で決めたパスに出力
    .pipe $.rename appConfig.CURRENT_DIR + page.path_filename
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

# sass compile process pc
g.task 'css-pc', ->
  g.src paths.pc.css.sass
  .pipe $.plumber(plumberConfig)
  .pipe $.if not isProduction, $.sourcemaps.init()
  # gulp-header を使用して JSON ファイルを sass 変数に読み込む
  .pipe $.header(
    '$SITE_URL: "' + appConfig.APP_SITE_URL + '";\n' +
    '$SITE_NAME: "' + appConfig.SITE_NAME + '";\n' +
    '$AUTHOR: "' + appConfig.AUTHOR + '";\n' +
    '$MODIFIER: "' + appConfig.MODIFIER + '";\n' +
    '$UPDATE: "' + appConfig.UPDATE + '";\n' +
    '$TIMESTAMP: "?v=' + appConfig.TIMESTAMP + '";\n'
  )
  .pipe $.sass({
    outputStyle: 'expanded'
    # functions:
    #   'getJson($path)': require './script/sassGetJson'
  }).on('error', $.sass.logError) # エラーでも止めない
  # postcss で画像サイズを取得し変換する
  .pipe $.postcss([
    require('postcss-assets')(
      loadPaths: [paths.common.img.postcss, paths.pc.img.postcss]
      basePath: paths.pc.dest
      relative: paths.pc.css.postcss
    )
    require('css-mqpacker')
    require('postcss-sorting')(
      require '../src/postcss-sorting.json' # 並び順の設定ファイル
    )
  ]).on('error', $.util.log) # エラーでも止めない
  .pipe $.autoprefixer browsers: ['> 0%']
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
    return

# coffee compile process pc
g.task 'coffee-pc', ->
  g.src([paths.pc.js.plugin, paths.pc.js.javascript, paths.pc.js.coffee])
  .pipe $.plumber(plumberConfig)
  .pipe $.webpack require './webpack.config.pc.coffee'
  .pipe $.if isProduction, $.header(commentsJs, pkg: appConfig, filename: 'メインスクリプト')
  .pipe g.dest paths.pc.js.dest
  # JS を stream オプションでリアルタイムに反映
  .pipe bs.stream()
  # sourcemaps を本番ビルド時に削除する
  .pipe $.if isProduction, pathSearch(paths.pc.js.dest, 'js').on 'end', (cb) ->
    pathArray.unshift(paths.pc.js.dest + '**/*.map')
    return

# img check pc
g.task 'img-pc-check', ->
  return g.src paths.pc.img.src
  .pipe $.plumber(plumberConfig)
  # src フォルダに存在しないファイルを htdocs から削除する
  .pipe pathSearch(rootDir.src + '/pc/images/', 'images').on 'end', (cb) ->
    pathArray.unshift(paths.pc.img.dest + '**/*.*')
    return

# img optimize pc
g.task 'img-pc', ['img-pc-check'], ->
  g.src paths.pc.img.src
  .pipe $.plumber(plumberConfig)
  # 画像に変更がない場合、出力しない
  .pipe $.changed(paths.pc.img.dest, { hasChanged: $.changed.compareSha1Digest })
  # .pipe $.imagemin()
  .pipe g.dest paths.pc.img.dest

# build pc
g.task 'build-pc', ->
  return runSequence 'import', 'libcopy', 'coffee', 'img', 'coffee-pc', 'img-pc', 'ect-pc', 'css-pc', 'remove-files'

#------------------------------------------------------
# Setting for SP
# SP 向け設定
#------------------------------------------------------

# ect json process sp
g.task 'ect-sp', ->
  jsonData = JSON.parse fs.readFileSync(paths.sp.ect.json)
  jsonDataLength = Object.keys(jsonData).length - 1
  jsonData.forEach (page, i) ->
    g.src rootDir.src + '/sp/templates/' + page.template + '.ect'
    .pipe $.plumber(plumberConfig)
    # ect で JSON ファイルを変数に読み込む
    .pipe $.data (file)->
      staticData = page
      staticData.RELATIVE_PATH = abspath2rel appConfig.CURRENT_DIR, '' + '../' + abspath2rel staticData.path_filename, ''
      staticData.SITE_URL = appConfig.APP_SITE_URL
      staticData.SITE_NAME = appConfig.SITE_NAME
      staticData.CURRENT_DIR = appConfig.CURRENT_DIR
      # 'index.html' を含まないファイルパスを出す
      staticData.FILE_PATH = staticData.path_filename.replace appConfig.CURRENT_DIR, ''
      staticData.FILE_PATH = staticData.FILE_PATH.replace 'index.html', ''
      # 'index.html' を含まないリダイレクトパスを出す
      staticData.REDIRECT_PATH = staticData.RELATIVE_PATH + appConfig.CURRENT_DIR + staticData.path_filename.replace 'index.html', ''
      return staticData
    .pipe $.ect(data: page)
    # pages.json に記述された 'path_filename' で決めたパスに出力
    .pipe $.rename appConfig.CURRENT_DIR + page.path_filename
    .pipe g.dest paths.sp.dest
    # html を stream オプションでリアルタイムに反映
    .pipe bs.stream()
    # src フォルダに存在しないファイルを htdocs から削除する
    .pipe pathSearch(paths.sp.dest, 'templates').on 'end', (cb) ->
      if i == jsonDataLength
        pathArray.unshift('!' + paths.sp.dest + 'index.html')
        pathArray.unshift(paths.sp.dest + '**/*.html')
      return

# sass compile process sp
g.task 'css-sp', ->
  g.src paths.sp.css.sass
  .pipe $.plumber(plumberConfig)
  .pipe $.if not isProduction, $.sourcemaps.init()
  # gulp-header を使用して JSON ファイルを sass 変数に読み込む
  .pipe $.header(
    '$SITE_URL: "' + appConfig.APP_SITE_URL + '";\n' +
    '$SITE_NAME: "' + appConfig.SITE_NAME + '";\n' +
    '$AUTHOR: "' + appConfig.AUTHOR + '";\n' +
    '$MODIFIER: "' + appConfig.MODIFIER + '";\n' +
    '$UPDATE: "' + appConfig.UPDATE + '";\n' +
    '$TIMESTAMP: "?v=' + appConfig.TIMESTAMP + '";\n'
  )
  .pipe $.sass({
    outputStyle: 'expanded'
    # functions:
    #   'getJson($path)': require './script/sassGetJson'
  }).on('error', $.sass.logError) # エラーでも止めない
  # postcss で画像サイズを取得し変換する
  .pipe $.postcss([
    require('postcss-assets')(
      loadPaths: [paths.common.img.postcss, paths.sp.img.postcss]
      basePath: paths.pc.dest
      relative: paths.sp.css.postcss
    )
    require('css-mqpacker')
    require('postcss-sorting')(
      require '../src/postcss-sorting.json' # 並び順の設定ファイル
    )
  ]).on('error', $.util.log) # エラーでも止めない
  .pipe $.autoprefixer browsers: ['> 0%']
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
    return

# coffee compile process sp
g.task 'coffee-sp', ->
  g.src([paths.sp.js.plugin, paths.sp.js.javascript, paths.sp.js.coffee])
  .pipe $.plumber(plumberConfig)
  .pipe $.webpack require './webpack.config.sp.coffee'
  .pipe $.if isProduction, $.header(commentsJs, pkg: appConfig, filename: 'メインスクリプト')
  .pipe g.dest paths.sp.js.dest
  # JS を stream オプションでリアルタイムに反映
  .pipe bs.stream()
  # sourcemaps を本番ビルド時に削除する
  .pipe $.if isProduction, pathSearch(paths.sp.js.dest, 'js').on 'end', (cb) ->
    pathArray.unshift(paths.sp.js.dest + '**/*.map')
    return

# img check sp
g.task 'img-sp-check', ->
  return g.src paths.sp.img.src
  .pipe $.plumber(plumberConfig)
  # src フォルダに存在しないファイルを htdocs から削除する
  .pipe pathSearch(rootDir.src + '/sp/images/', 'images').on 'end', (cb) ->
    pathArray.unshift(paths.sp.img.dest + '**/*.*')
    return

# img optimize sp
g.task 'img-sp', ['img-sp-check'], ->
  g.src paths.sp.img.src
  .pipe $.plumber(plumberConfig)
  # 画像に変更がない場合、出力しない
  .pipe $.changed(paths.sp.img.dest, { hasChanged: $.changed.compareSha1Digest })
  # .pipe $.imagemin()
  .pipe g.dest paths.sp.img.dest

# build sp
g.task 'build-sp', ->
  return runSequence 'import', 'libcopy', 'coffee', 'img', 'coffee-sp', 'img-sp', 'ect-sp', 'css-sp', 'remove-files'

#------------------------------------------------------
# Differential data extraction
# 差分データ抽出
#------------------------------------------------------

# diff process
g.task 'diff', ['clean', 'clean-temp'], ->
  if appConfig.RESPONSIVE_TEMPLATE == 'true'
    return runSequence 'import', 'libcopy', 'coffee', 'img', 'ect-rp', 'css-rp', 'coffee-rp', 'img-rp', 'temp'
  else
    return runSequence 'import', 'libcopy', 'coffee', 'img', 'ect-pc', 'css-pc', 'coffee-pc', 'img-pc', 'ect-sp', 'css-sp', 'coffee-sp', 'img-sp', 'temp'

# temp process
g.task 'temp', ->
  g.src paths.archive.src
  .pipe $.plumber(plumberConfig)
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
  .pipe $.plumber(plumberConfig)
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

# remove files
g.task 'remove-files', (cb) ->
  return del pathArray, cb

# clean
g.task 'clean', (cb) ->
  if appConfig.RESPONSIVE_TEMPLATE == 'true'
    return rimraf paths.rp.dest, cb
  else
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
    g.start 'img' # img ファイルが変更または追加されたらビルド出力

# watch rp
g.task 'watch-rp', ['bs'], ->
  g.watch [paths.rp.ect.watch, paths.rp.ect.json], ['ect-rp']
  g.watch paths.rp.css.watch, ['css-rp']
  g.watch [paths.rp.js.plugin, paths.rp.js.javascript, paths.rp.js.coffee], ['coffee-rp']
  $.watch paths.rp.img.src, ->
    g.start 'img-rp' # img ファイルが変更または追加されたらビルド出力

# watch pc
g.task 'watch-pc', ['bs'], ->
  g.watch [paths.pc.ect.watch, paths.pc.ect.json], ['ect-pc']
  g.watch paths.pc.css.watch, ['css-pc']
  g.watch [paths.pc.js.plugin, paths.pc.js.javascript, paths.pc.js.coffee], ['coffee-pc']
  $.watch paths.pc.img.src, ->
    g.start 'img-pc' # img ファイルが変更または追加されたらビルド出力

# watch sp
g.task 'watch-sp', ['bs'], ->
  g.watch [paths.sp.ect.watch, paths.sp.ect.json], ['ect-sp']
  g.watch paths.sp.css.watch, ['css-sp']
  g.watch [paths.sp.js.plugin, paths.sp.js.javascript, paths.sp.js.coffee], ['coffee-sp']
  $.watch paths.sp.img.src, ->
    g.start 'img-sp' # img ファイルが変更または追加されたらビルド出力

# default task
if appConfig.RESPONSIVE_TEMPLATE == 'true'
  g.task 'default', ['bs', 'watch-rp', 'watch']
else
  g.task 'default', ['bs', 'watch-pc', 'watch-sp', 'watch']