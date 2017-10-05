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
      document.querySelector(i_target).addEventListener 'click', ((e) ->
        e.preventDefault()
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
      document.querySelector(i_target).addEventListener 'click', ((e) ->
        e.preventDefault()
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
      document.querySelector(i_target).addEventListener 'click', ((e) ->
        e.preventDefault()
        if mobileType[0] is 'mobile'
          url = 'http://line.me/R/msg/text/?'
          url += encodeURIComponent(i_text)
          url += '%20' + encodeURIComponent(i_url)
        else
          url = 'https://timeline.line.me/social-plugin/share?url='
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
  # Google+のシェアダイアログを表示
  #------------------------------------------------------

  @googleShare: (i_target, i_url) ->
    if document.querySelector(i_target) != null
      document.querySelector(i_target).addEventListener 'click', ((e) ->
        e.preventDefault()
        url = 'https://plus.google.com/share?url='
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
  # 文字をカーニング調整
  #------------------------------------------------------

  # CSS設定 @type {{first: string, rspace: string, rspace2: string}}
  textKerningCSS =
    first: '-.5em'
    rspace: '-.75em'
    rspace2: '-.5em'

  # カーニングのやつ @param $target
  @textKerning: ($target) ->
    Array::forEach.call document.querySelectorAll($target), (el, i) ->
      __$target = el

      # altとtitleをいったん格納する
      __alt = []
      __title = []
      __$img = __$target.getElementsByTagName('img')
      __$a = __$target.getElementsByTagName('a')
      if __$img.length > 0
        Array::forEach.call __$img, (el, i) ->
          __alt.push el.getAttribute('alt')
          el.setAttribute 'alt', ''
          return
      if __$a.length > 0
        Array::forEach.call __$a, (el, i) ->
          __title.push el.getAttribute('title')
          el.setAttribute 'title', ''
          return

      # もにょもにょする
      __text = __$target.innerHTML
      __text = __text.replace(/^(\s|\t|\n)+|(\s|\t|\n)+$/g, '') #文章の頭とケツの半角・全角スペース、タブ、改行削除
      __text = __text.replace(/(\n)((\s|\t)+)/g, '') #改行後の頭の半角・全角スペース、タブ削除
      __text = __text.replace(/^(（|〔|［|｛|〈|《|「|『|【)/g, '<span class=\'rspace-first\'>$1</span>') #文頭調整
      __text = __text.replace(/(<br \/>|<br>)(（|〔|［|｛|〈|《|「|『|【)/g, '$1<span class=\'rspace-first\'>$2</span>') #br改行後の文頭調整
      __text = __text.replace(/(、|。|，|．|）|〕|］|｝|〉|》|」|』|】)(、|。|，|．|）|〕|］|｝|〉|》|」|』|】)(（|〔|［|｛|〈|《|「|『|【)/g, '<span class=\'rspace2\'>$1</span><span class=\'rspace\'>$2</span>$3')
      __text = __text.replace(/(、|。|，|．|）|〕|］|｝|〉|》|」|』|】)(（|〔|［|｛|〈|《|「|『|【)/g, '<span class=\'rspace2\'>$1</span>$2')
      __$target.innerHTML = __text
      target = __$target.querySelectorAll('.rspace-first')
      target2 = __$target.querySelectorAll('.rspace')
      target3 = __$target.querySelectorAll('.rspace2')
      i = 0
      while i < target.length
        target[i].style.position = 'relative'
        target[i].style.left = textKerningCSS.first
        target[i].style.letterSpacing = textKerningCSS.first
        i++
      i = 0
      while i < target2.length
        target2[i].style.letterSpacing = textKerningCSS.rspace
        i++
      i = 0
      while i < target3.length
        target3[i].style.letterSpacing = textKerningCSS.rspace2
        i++

      # altとtitleつけなおす
      __$img = __$target.getElementsByTagName('img')
      __$a = __$target.getElementsByTagName('a')
      if __$img.length > 0
        Array::forEach.call __$img, (el, i) ->
          el.setAttribute 'alt', __alt[i]
          return
      if __$a.length > 0
        Array::forEach.call __$a, (el, i) ->
          el.setAttribute 'title', __title[i]
          return

      return
    return

module.exports = Common