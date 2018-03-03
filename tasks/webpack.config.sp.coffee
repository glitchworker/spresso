#------------------------------------------------------
# Load dependencies module
# 依存モジュール読み込み
#------------------------------------------------------

webpack = require('gulp-webpack').webpack # Webpack 読み込み
minimist = require 'minimist' # Gulp で引数を解析
merge = require 'webpack-merge' # 共通の Webpack 設定をマージ

#------------------------------------------------------
# Load original module
# 独自モジュール読み込み
#------------------------------------------------------

baseConfig = require './webpack.config.base.coffee' # Webpack 共通設定

#------------------------------------------------------
# Development & Production Environment Branch processing
# 開発＆本番環境の振り分け処理
#------------------------------------------------------

options = minimist process.argv.slice(2), envOption

envOption =
  string: 'env'
  default: env: process.env.NODE_ENV or 'development'

isProduction = options.env == 'production' or options.env == 'staging'

#------------------------------------------------------
# Merge Webpack settings of development & production environment
# 開発＆本番環境の Webpack の設定をマージ
#------------------------------------------------------

outputName = 'app'
config = merge baseConfig,
  output:
    filename: outputName + '.js' # 出力するファイル名
    sourceMapFilename: if not isProduction then outputName + '.map' # 出力するマップファイル名

module.exports = config