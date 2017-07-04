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

    #------------------------------------------------------
    # Social Share - SNSシェアボタンの処理
    #------------------------------------------------------

    document.addEventListener 'DOMContentLoaded', (->
      SITE_URL = location.href.replace('#', '') + location.search
      SITE_SHARE = document.querySelector('meta[property="og:description"]').getAttribute('content')
      Common.twitterShare '.tw', SITE_URL, SITE_SHARE
      Common.facebookShare '.fb', SITE_URL
      Common.lineShare '.li', SITE_URL, SITE_SHARE
      return
    ), false

new Index()