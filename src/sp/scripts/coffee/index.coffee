class Index

  constructor: ->
    if Common.getName(this.constructor.name)
      @init()

  init: ->
    @main()

  main: ->
    # console.log 'index'

new Index()