#------------------------------------------------------
# Load module
# モジュール読み込み
#------------------------------------------------------

webpack = require('gulp-webpack').webpack # Webpack 読み込み
minimist = require 'minimist' # Gulp で引数を解析
merge = require 'webpack-merge' # 共通の Webpack 設定をマージ
baseConfig = require './webpack.config.base.coffee' # Webpack 共通設定

#------------------------------------------------------
# Development & Production Environment Branch processing
# 開発＆本番環境の振り分け処理
#------------------------------------------------------

options = minimist process.argv.slice(2), envOption

envOption =
  string: 'env'
  default: env: process.env.NODE_ENV or 'development'

isProduction = options.env == 'production'

#------------------------------------------------------
# Merge Webpack settings of development & production environment
# 開発＆本番環境の Webpack の設定をマージ
#------------------------------------------------------

outputName = 'common'
commonPath = './common'
config = merge baseConfig,
  output:
    filename: outputName + '.js' # 出力するファイル名
    sourceMapFilename: if not isProduction then outputName + '.map' # 出力するマップファイル名
  devtool: if not isProduction then 'source-map'
  plugins: if not isProduction then [
    new webpack.ProvidePlugin
      Common: commonPath # common.coffee を Common という名前で共通で require する
  ] else [
    new webpack.ProvidePlugin
      Common: commonPath # common.coffee を Common という名前で共通で require する
    new webpack.optimize.UglifyJsPlugin({
      preserveComments: 'some' # Licence 表記を消さない
      compress:
        warnings: false
        drop_console: true
    })
  ]

module.exports = config