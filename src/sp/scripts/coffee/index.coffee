class Index

  constructor: ->
    if Common.getName('Index')
      @init()

  init: ->
    @main()

  main: ->
    # console.log 'index'

new Index()