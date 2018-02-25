#------------------------------------------------------
# Load dependencies module
# 依存モジュール読み込み
#------------------------------------------------------

path = require 'path' # パス解析
webpack = require('gulp-webpack').webpack # Webpack 読み込み
minimist = require 'minimist' # Gulp で引数を解析
IfPlugin = require 'if-webpack-plugin' # Webpack の Plugins 内で条件分岐

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

isProduction = if options.env == 'production' then true else false

if isProduction
  APP_SITE_URL = appConfig.PROD_SITE_URL
else
  APP_SITE_URL = appConfig.DEV_SITE_URL

#------------------------------------------------------
# WebPack Modules
# WebPack のモジュール設定
#------------------------------------------------------

commonPath = path.resolve('') + '/src/common/scripts/coffee/common'
config = {
  devtool: if not isProduction then 'source-map'
  resolve: {
    extensions: ['', '.js', '.coffee'] # require する際に、拡張子を省略するための設定
  }
  module:
    loaders: [
      {test: /\.coffee$/, loader: 'coffee-loader'} # CoffeeScript をコンパイルするための設定
    ]
  plugins: [
    new webpack.ProvidePlugin
      Common: commonPath # common.coffee を Common という名前で共通で require する
    new webpack.DefinePlugin
      'APP_BASE_SITE_URL': JSON.stringify APP_SITE_URL
      'APP_SITE_URL': JSON.stringify APP_SITE_URL + appConfig.CURRENT_DIR
      'APP_SITE_NAME': JSON.stringify appConfig.SITE_NAME
      'APP_AUTHOR': JSON.stringify appConfig.AUTHOR
      'APP_MODIFIER': JSON.stringify appConfig.MODIFIER
      'APP_UPDATE': JSON.stringify update
      'APP_TIMESTAMP':JSON.stringify timestamp
    new IfPlugin(
      isProduction
      new webpack.optimize.UglifyJsPlugin
        preserveComments: 'some' # Licence 表記を消さない
        compress:
          warnings: false
          drop_console: true
    )
  ]
}

module.exports = config