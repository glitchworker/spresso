Selector = require './modules/Selector'

class Index

  constructor: ->
    Selector = new Selector()
    @init()

  init: ->
    @main()

  main: ->
    #------------------------------------------------------
    # Redirect Scripts - PCとSPのリダイレクト処理
    #------------------------------------------------------

    _isMobile = mobileType[0] is "mobile"

    window.redirectPC = (url) ->
      _isMobile or (location.href = url + location.search)
    window.redirectSP = (url) ->
      (_isMobile) and (location.href = url + location.search)

new Index()