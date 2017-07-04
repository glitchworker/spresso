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

module.exports = Common