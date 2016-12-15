_ = require 'underscore'
sass = require 'gulp-sass'
path = require 'path'

sassGetJson = (json)->

  data = require path.resolve('') + '/' + json.getValue()

  keys = _.keys data
  map = new sass.compiler.types.Map keys.length

  for val, i in keys
    map.setKey i, sass.compiler.types.String(val)
    map.setValue i, sass.compiler.types.String(data[val])

  return map

module.exports = sassGetJson