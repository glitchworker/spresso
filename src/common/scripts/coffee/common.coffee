class window.Common

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

  #------------------------------------------------------
  # 指定要素のスクロールを無効化
  #
  # 無効化の例：
  # modal = document.querySelector('.modal_list')
  # Common.disableBodyScroll modal, reserveScrollBarGap: true
  #
  # 有効化の例：
  # Common.enableBodyScroll modal
  #------------------------------------------------------

  _toConsumableArray = (arr) ->
    if Array.isArray(arr)
      i = 0
      arr2 = Array(arr.length)
      while i < arr.length
        arr2[i] = arr[i]
        i++
      arr2
    else
      Array.from arr

  # Passive Event が対応しているかどうかを判断
  # https://stackoverflow.com/questions/41594997/ios-10-safari-prevent-scrolling-behind-a-fixed-overlay-and-maintain-scroll-posi
  hasPassiveEvents = false
  if typeof window != 'undefined'
    passiveTestOptions = Object.defineProperty({}, 'passive', get: ->
      hasPassiveEvents = true
      undefined
    )
    window.addEventListener 'testPassive', null, passiveTestOptions
    window.removeEventListener 'testPassive', null, passiveTestOptions

  isIosDevice = typeof window != 'undefined' and window.navigator and window.navigator.platform and /iP(ad|hone|od)/.test(window.navigator.platform)
  locks = []
  documentListenerAdded = false
  initialClientY = -1
  previousBodyOverflowSetting = undefined
  previousBodyPaddingRight = undefined

  allowTouchMove = (el) ->
    locks.some (lock) ->
      if lock.options.allowTouchMove and lock.options.allowTouchMove(el)
        return true
      false

  preventDefault = (rawEvent) ->
    e = rawEvent or window.event
    if allowTouchMove(e.target)
      return true
    if e.touches.length > 1
      return true
    if e.preventDefault
      e.preventDefault()
    false

  setOverflowHidden = (options) ->
    setTimeout ->
      if previousBodyPaddingRight == undefined
        _reserveScrollBarGap = ! !options and options.reserveScrollBarGap == true
        scrollBarGap = window.innerWidth - (document.documentElement.clientWidth)
        if _reserveScrollBarGap and scrollBarGap > 0
          previousBodyPaddingRight = document.body.style.paddingRight
          document.body.style.paddingRight = scrollBarGap + 'px'
      if previousBodyOverflowSetting == undefined
        previousBodyOverflowSetting = document.body.style.overflow
        document.body.style.overflow = 'hidden'
      return
    return

  restoreOverflowSetting = ->
    setTimeout ->
      if previousBodyPaddingRight != undefined
        document.body.style.paddingRight = previousBodyPaddingRight
        previousBodyPaddingRight = undefined
      if previousBodyOverflowSetting != undefined
        document.body.style.overflow = previousBodyOverflowSetting
        previousBodyOverflowSetting = undefined
      return
    return

  # https://developer.mozilla.org/en-US/docs/Web/API/Element/scrollHeight#Problems_and_solutions
  isTargetElementTotallyScrolled = (targetElement) ->
    if targetElement then targetElement.scrollHeight - (targetElement.scrollTop) <= targetElement.clientHeight else false

  handleScroll = (event, targetElement) ->
    clientY = event.targetTouches[0].clientY - initialClientY
    if allowTouchMove(event.target)
      return false
    if targetElement and targetElement.scrollTop == 0 and clientY > 0
      return preventDefault(event)
    if isTargetElementTotallyScrolled(targetElement) and clientY < 0
      return preventDefault(event)
    event.stopPropagation()
    true

  @disableBodyScroll = (targetElement, options) ->
    if isIosDevice
      if !targetElement
        console.error 'disableBodyScroll unsuccessful - targetElement must be provided when calling disableBodyScroll on IOS devices.'
        return
      if targetElement and !locks.some(((lock) ->
          lock.targetElement == targetElement
        ))
        lock =
          targetElement: targetElement
          options: options or {}
        locks = [].concat(_toConsumableArray(locks), [ lock ])
        targetElement.ontouchstart = (event) ->
          if event.targetTouches.length == 1
            initialClientY = event.targetTouches[0].clientY
          return
        targetElement.ontouchmove = (event) ->
          if event.targetTouches.length == 1
            handleScroll event, targetElement
          return
        if !documentListenerAdded
          document.addEventListener 'touchmove', preventDefault, if hasPassiveEvents then passive: false else undefined
          documentListenerAdded = true
    else
      setOverflowHidden options
      _lock =
        targetElement: targetElement
        options: options or {}
      locks = [].concat(_toConsumableArray(locks), [ _lock ])
    return

  @clearAllBodyScrollLocks = ->
    if isIosDevice
      locks.forEach (lock) ->
        lock.targetElement.ontouchstart = null
        lock.targetElement.ontouchmove = null
        return
      if documentListenerAdded
        document.removeEventListener 'touchmove', preventDefault, if hasPassiveEvents then passive: false else undefined
        documentListenerAdded = false
      locks = []
      initialClientY = -1
    else
      restoreOverflowSetting()
      locks = []
    return

  @enableBodyScroll = (targetElement) ->
    if isIosDevice
      if !targetElement
        console.error 'enableBodyScroll unsuccessful - targetElement must be provided when calling enableBodyScroll on IOS devices.'
        return
      targetElement.ontouchstart = null
      targetElement.ontouchmove = null
      locks = locks.filter((lock) ->
        lock.targetElement != targetElement
      )
      if documentListenerAdded and locks.length == 0
        document.removeEventListener 'touchmove', preventDefault, if hasPassiveEvents then passive: false else undefined
        documentListenerAdded = false
    else if locks.length == 1 and locks[0].targetElement == targetElement
      restoreOverflowSetting()
      locks = []
    else
      locks = locks.filter((lock) ->
        lock.targetElement != targetElement
      )
    return

module.exports = Common