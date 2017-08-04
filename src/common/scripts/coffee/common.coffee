class Common

  #------------------------------------------------------
  # ページ内 Body のクラスを取得
  #------------------------------------------------------

  @getName: (str) ->
    document.querySelector('body.page-' + str.toLowerCase())

  #------------------------------------------------------
  # URLからパラメータを取得
  #------------------------------------------------------

  @getParam: () ->
    array = []
    param = location.search.substring(1).split('&')
    i = 0
    while param[i]
      keyValue = param[i].split('=')
      array[keyValue[0]] = keyValue[1]
      i++
    array

  #------------------------------------------------------
  # 配列をシャッフルする
  #------------------------------------------------------

  @shuffleArray: (array) ->
    length = array.length
    i = length - 1
    while i > 0
      j = Math.floor(Math.random() * (i + 1))
      tmp = array[i]
      array[i] = array[j]
      array[j] = tmp
      i--
    array

  #------------------------------------------------------
  # 指定した文字数で分割し配列で返す
  #------------------------------------------------------

  @splitByLength: (str, length) ->
    resultArr = []
    if !str or !length or length < 1
      return resultArr
    index = 0
    start = index
    end = start + length
    while start < str.length
      resultArr[index] = str.substring(start, end)
      index++
      start = end
      end = start + length
    resultArr

  #------------------------------------------------------
  # Twitterのシェアダイアログを表示
  #------------------------------------------------------

  @twitterShare: (i_target, i_url, i_text) ->
    if document.querySelector(i_target) != null
      document.querySelector(i_target).addEventListener 'click', (->
        url = 'http://twitter.com/share?url='
        url += encodeURIComponent(i_url)
        url += '&text=' + encodeURIComponent(i_text)
        window.open url, 'share', [
          'width=550'
          'height=450'
          'location=yes'
          'resizable=yes'
          'toolbar=no'
          'menubar=no'
          'scrollbars=no'
          'status=no'
        ].join(',')
        false
      ), false
    return

  #------------------------------------------------------
  # Facebookのシェアダイアログを表示
  #------------------------------------------------------

  @facebookShare: (i_target, i_url) ->
    if document.querySelector(i_target) != null
      document.querySelector(i_target).addEventListener 'click', (->
        url = 'http://www.facebook.com/share.php?u='
        url += encodeURIComponent(i_url)
        window.open url, 'share', [
          'width=550'
          'height=450'
          'location=yes'
          'resizable=yes'
          'toolbar=no'
          'menubar=no'
          'scrollbars=no'
          'status=no'
        ].join(',')
        false
      ), false
    return

  #------------------------------------------------------
  # LINEのシェアダイアログを表示
  #------------------------------------------------------

  @lineShare: (i_target, i_url, i_text) ->
    if document.querySelector(i_target) != null
      document.querySelector(i_target).addEventListener 'click', (->
        url = 'http://line.me/R/msg/text/?'
        url += encodeURIComponent(i_text)
        url += '%20' + encodeURIComponent(i_url)
        console.log url
        window.open url, 'share', [
          'width=550'
          'height=450'
          'location=yes'
          'resizable=yes'
          'toolbar=no'
          'menubar=no'
          'scrollbars=no'
          'status=no'
        ].join(',')
        false
      ), false
    return

  #------------------------------------------------------
  # 文字をカーニング調整
  #------------------------------------------------------

  # CSS設定 @type {{first: string, rspace: string, rspace2: string}}
  _defaultCSS =
    first: '-.5em'
    rspace: '-.75em'
    rspace2: '-.5em'

  # カーニングのやつ @param $target
  @textKerning: ($target) ->
    $target.each ->
      __$target = $(this)

      # altとtitleをいったん格納する
      __alt = []
      __title = []
      __$img = __$target.find('img')
      __$a = __$target.find('a')
      if __$img.length > 0
        __$img.each ->
          __alt.push $(this).attr('alt')
          $(this).removeAttr 'alt'
          return
      if __$a.length > 0
        __$a.each ->
          __title.push $(this).attr('title')
          $(this).removeAttr 'title'
          return

      # もにょもにょする
      __text = __$target.html()
      __text = __text.replace(/^(\s|\t|\n)+|(\s|\t|\n)+$/g, '') #文章の頭とケツの半角・全角スペース、タブ、改行削除
      __text = __text.replace(/(\n)((\s|\t)+)/g, '') #改行後の頭の半角・全角スペース、タブ削除
      __text = __text.replace(/^(（|〔|［|｛|〈|《|「|『|【)/g, '<span class=\'rspace-first\'>$1</span>') #文頭調整
      __text = __text.replace(/(<br \/>|<br>)(（|〔|［|｛|〈|《|「|『|【)/g, '$1<span class=\'rspace-first\'>$2</span>') #br改行後の文頭調整
      __text = __text.replace(/(、|。|，|．|）|〕|］|｝|〉|》|」|』|】)(、|。|，|．|）|〕|］|｝|〉|》|」|』|】)(（|〔|［|｛|〈|《|「|『|【)/g, '<span class=\'rspace2\'>$1</span><span class=\'rspace\'>$2</span>$3')
      __text = __text.replace(/(、|。|，|．|）|〕|］|｝|〉|》|」|』|】)(（|〔|［|｛|〈|《|「|『|【)/g, '<span class=\'rspace2\'>$1</span>$2')
      __$target.html __text
      __$target.find('.rspace-first').css
        position: 'relative'
        left: _defaultCSS.first
        letterSpacing: _defaultCSS.first
      __$target.find('.rspace').css letterSpacing: _defaultCSS.rspace
      __$target.find('.rspace2').css letterSpacing: _defaultCSS.rspace2

      # altとtitleつけなおす
      __$img = __$target.find('img')
      __$a = __$target.find('a')
      if __$img.length > 0
        __$img.each (i) ->
          $(this).attr 'alt': __alt[i]
          return
      if __$a.length > 0
        __$a.each (i) ->
          $(this).attr 'title': __title[i]
          return

      return
    return

module.exports = Common