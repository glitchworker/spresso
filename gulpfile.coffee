#------------------------------------------------------
# /tasks/ Directory recursively
# /tasks/ ディレクトリを再帰的に読み込み
#------------------------------------------------------

dir = require 'require-dir'
dir './tasks', { recurse: true }