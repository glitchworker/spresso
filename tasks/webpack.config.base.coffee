#------------------------------------------------------
# Load dependencies module
# 依存モジュール読み込み
#------------------------------------------------------

path = require 'path' # パス解析
webpack = require('webpack-stream').webpack # Webpack 読み込み
minimist = require 'minimist' # Gulp で引数を解析
IfPlugin = require 'if-webpack-plugin' # Webpack の 条件分岐
UglifyJSPlugin = require 'uglifyjs-webpack-plugin' # Webpack の minify 設定
HardSourcePlugin = require 'hard-source-webpack-plugin' # 中間キャッシュでビルド時間を短縮

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
isMode = if options.env == 'production' or options.env == 'staging' then 'production' else 'development'

if isProduction
  if isStaging
    APP_SITE_URL = appConfig.STG_SITE_URL
  else
    APP_SITE_URL = appConfig.PROD_SITE_URL
else
  APP_SITE_URL = appConfig.DEV_SITE_URL

#------------------------------------------------------
# WebPack Modules
# WebPack のモジュール設定
#------------------------------------------------------

# commonPath = path.resolve('') + '/src/common/scripts/coffee/common'
config = {
  mode: isMode
  devtool: if not isProduction then 'source-map'
  resolve: {
    extensions: ['.js', '.coffee'] # require する際に、拡張子を省略するための設定
  }
  module:
    rules: [
      {
        test: /\.coffee$/,
        use: [
          {
            loader: 'babel-loader'
            options:
              presets: ['@babel/preset-env']
              plugins: [
                ['@babel/plugin-transform-classes', { 'loose': true }] # ES6 を ES5 に変換
              ]
          }
          'coffee-loader' # CoffeeScript をコンパイルするための設定
        ]
      }
    ]
  plugins: [
    # new webpack.ProvidePlugin
    #   Common: commonPath # common.coffee を Common という名前で共通で require する
    new webpack.DefinePlugin
      'APP_BASE_SITE_URL': JSON.stringify APP_SITE_URL
      'APP_SITE_URL': JSON.stringify APP_SITE_URL + appConfig.CURRENT_DIR
      'APP_SITE_NAME': JSON.stringify appConfig.SITE_NAME
      'APP_AUTHOR': JSON.stringify appConfig.AUTHOR
      'APP_MODIFIER': JSON.stringify appConfig.MODIFIER
      'APP_UPDATE': JSON.stringify update
      'APP_TIMESTAMP':JSON.stringify timestamp
    new HardSourcePlugin(
      # cacheDirectory: '.cache/hard-source/[confighash]'
    )
  ]
  # Webpack 4 で minify の詳細設定するための記述
  optimization: {
    minimizer: [
      new IfPlugin(
        isProduction
        new UglifyJSPlugin
          uglifyOptions:
            output:
              comments: /^\**!|@preserve|@license|@cc_on/ # Licence 表記を消さない
            compress:
              drop_console: true # console.log を削除
      )
    ]
  }
}

module.exports = config