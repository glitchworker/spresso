import Selector from './modules/Selector'

class Index

  constructor: ->
    @init()

  init: ->
    @main()

  main: ->
    #------------------------------------------------------
    # Redirect Scripts - PCとSPのリダイレクト処理
    #------------------------------------------------------

    _isMobile = mobileType[0] is 'mobile'

    window.redirectPC = (url) ->
      _isMobile or (location.href = url + location.search)
    window.redirectSP = (url) ->
      (_isMobile) and (location.href = url + location.search)

    #------------------------------------------------------
    # DOMContentLoaded - 初回読み込み後に実行
    #------------------------------------------------------

    document.addEventListener 'DOMContentLoaded', (->

      # Social Share - SNSシェアボタンの処理
      SITE_URL = location.href.replace('#', '') + location.search
      SITE_SHARE = document.querySelector('meta[property="og:description"]').getAttribute('content')

      Common.twitterShare '.tw', SITE_URL, SITE_SHARE
      Common.facebookShare '.fb', SITE_URL
      Common.lineShare '.li', SITE_URL, SITE_SHARE
      Common.googleShare '.gp', SITE_URL

      # Font Kerning - フォントのカーニング処理
      Common.textKerning '.kerning'

      return
    ), false

new Index()