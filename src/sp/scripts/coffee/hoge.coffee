class Hoge

  constructor: ->
    if Common.getName 'Hoge'
      @hoge()
    else if Common.getName 'Hoge_fuga'
      @hoge_fuga()

  hoge: ->
    # console.log 'hoge'

  hoge_fuga: ->
    # console.log 'hoge_fuga'

new Hoge()