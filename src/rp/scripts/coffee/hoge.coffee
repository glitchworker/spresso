class Hoge

  constructor: ->
    if Common.getName 'Hoge'
      @init()

  init: ->
    @main()

  main: ->
    # console.log 'Hoge'

new Hoge()