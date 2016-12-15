class Hoge

  constructor: ->
    if Common.getName(this.constructor.name)
      @init()

  init: ->
    @main()

  main: ->
    # console.log 'Hoge'

new Hoge()