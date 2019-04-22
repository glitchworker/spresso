#------------------------------------------------------
# UserAgent Browser Selector - ブラウザクラス振り分け
#------------------------------------------------------

class Selector

  constructor: ->
    @init()

  init: ->

    selector = (u, n) ->
      e = document.documentElement
      l = []
      n = (if n then n else "")
      userAgent.ua = u.toLowerCase()
      l = l.concat(userAgent.getPlatform())
      l = l.concat(userAgent.getMobile())
      l = l.concat(userAgent.getBrowser())
      l = l.concat(userAgent.getIpadApp())
      l = l.concat(userAgent.getLang())
      l = l.concat(screenInfo.getPixelRatio())
      l = l.concat(screenInfo.getInfo())
      l = l.concat([ "js" ])

      updateScreen = ->
        e.className = e.className.replace(RegExp(" ?orientation_\\w+", "g"), "").replace(RegExp(" [min|max|cl]+[w|h]_\\d+", "g"), "")
        e.className = e.className + " " + screenInfo.getInfo().join(" ")

      if window.addEventListener
        window.addEventListener "resize", updateScreen
        window.addEventListener "orientationchange", updateScreen
      else
        window.attachEvent "resize", updateScreen
        window.attachEvent "orientationchange", updateScreen

      data = dataUriInfo.getImg()
      data.onload = data.onerror = ->
        e.className += " " + dataUriInfo.checkSupport().join(" ")

      unless Array::filter # IE Fix
        Array::filter = (fun) -> #, thisp
          "use strict"
          throw new TypeError()  if this is undefined or this is null
          t = Object(this)
          len = t.length >>> 0
          throw new TypeError()  if typeof fun isnt "function"
          res = []
          thisp = arguments[1]
          i = 0

          while i < len
            if i of t
              val = t[i]
              res.push val  if fun.call(thisp, val, i, t)
            i++
          res
      l = l.filter((e) ->
        e
      )
      l[0] = (if n then n + l[0] else l[0])
      e.className = l.join(" " + n)
      e.className

    userAgent =
      ua: ""
      is: (t) ->
        RegExp(t, "i").test userAgent.ua

      version: (p, n) ->
        n = n.replace(".", "_")
        i = n.indexOf("_")
        v = ""
        while i > 0
          v += " " + p + n.substring(0, i)
          i = n.indexOf("_", i + 1)
        v += " " + p + n
        v

      getIphoneDeviceName: ->
        is_ = userAgent.is
        if is_('iphone')
          version = ' '
          if (window.screen.width == 414 and window.screen.height == 896) or (window.screen.width == 896 and window.screen.height == 414) and window.devicePixelRatio == 3
            version += 'iphoneXSMax'
          else if (window.screen.width == 414 and window.screen.height == 896) or (window.screen.width == 896 and window.screen.height == 414) and window.devicePixelRatio == 2
            version += 'iphoneXR'
          else if (window.screen.width == 375 and window.screen.height == 812) or (window.screen.width == 812 and window.screen.height == 375) and window.devicePixelRatio == 3
            version += 'iphoneX iphoneXS'
          else if (window.screen.width == 414 and window.screen.height == 736) or (window.screen.width == 736 and window.screen.height == 414) and window.devicePixelRatio == 3
            version += 'iphone6_plus iphone7_plus iphone6s_plus iphone7s_plus iphone8_plus'
          else if (window.screen.width == 375 and window.screen.height == 667) or (window.screen.width == 667 and window.screen.height == 375) and window.devicePixelRatio == 2
            version += 'iphone6 iphone6s iphone7 iphone7s iphone8'
          else if (window.screen.width == 320 and window.screen.height == 568) or (window.screen.width == 568 and window.screen.height == 320) and window.devicePixelRatio == 2
            version += 'iphone5 iphone5s iphone5c'
          else if (window.screen.width == 320 and window.screen.height == 480) or (window.screen.width == 480 and window.screen.height == 320) and window.devicePixelRatio == 2
            version += 'iphone4 iphone4s'
          else if (window.screen.width == 320 and window.screen.height == 480) or (window.screen.width == 480 and window.screen.height == 320) and window.devicePixelRatio == 1
            version += 'iphone3 iphone3g iphone3gs'
          else
            version = ''
        else
          version = ''
        return version

      getPlatform: ->
        ua = userAgent.ua
        ver = userAgent.version
        is_ = userAgent.is
        [ (if is_("ipad|ipod|iphone") then (((if /CPU( iPhone)? OS (\d+[_|\.]\d+([_|\.]\d+)*)/i.test(ua) then "ios" + ver("ios", RegExp.$2) else "")) + " " + ((if /(ip(ad|od|hone))/g.test(ua) then RegExp.$1 else "")) + "" + ((if /(iphone)/g.test(ua) then userAgent.getIphoneDeviceName() else ""))) else (if is_("mac") then "mac" + ((if /mac os x ((\d+)[.|_](\d+))/.test(ua) then (" mac" + (RegExp.$2) + " mac" + (RegExp.$1).replace(".", "_")) else "")) else (if is_("win") then "win" + ((if is_("windows nt 6.3") then " win8_1" else (if is_("windows nt 6.2") then " win8" else (if is_("windows nt 6.1") then " win7" else (if is_("windows nt 6.0") then " vista" else (if is_("windows nt 5.2") or is_("windows nt 5.1") then " win_xp" else (if is_("windows nt 5.0") then " win_2k" else (if is_("windows nt 4.0") or is_("WinNT4.0") then " win_nt" else "")))))))) else (if is_("freebsd") then "freebsd" else (if is_("x11|linux") then "linux" else (if is_("playbook") then "playbook" else (if is_("kindle|silk") then "kindle" else (if is_("playbook") then "playbook" else (if is_("j2me") then "j2me" else ""))))))))) ]

      getMobile: ->
        is_ = userAgent.is
        [ (if is_("android|iphone|ipod|ipad|mobi|mobile|j2me|blackberry|playbook|kindle|silk") then "mobile" else "") ]

      getBrowser: ->
        g = "gecko"
        w = "webkit"
        c = "chrome"
        f = "firefox"
        s = "safari"
        o = "opera"
        a = "android"
        b = "blackberry"
        d = "device_"
        ua = userAgent.ua
        is_ = userAgent.is
        [ (if (not (/opera|webtv|firefox/i.test(ua)) and /trident|msie/i.test(ua) and /(msie\s|rv\:)(\d+)/.test(ua)) then ("ie ie" + ((if /trident\/4\.0/.test(ua) then "8" else RegExp.$2))) else (if is_("firefox/") then g + " " + f + ((if /firefox\/((\d+)(\.(\d+))(\.\d+)*)/.test(ua) then " " + f + RegExp.$2 + " " + f + RegExp.$2 + "_" + RegExp.$4 else "")) else (if is_("gecko/") then g else (if is_("opera") then o + ((if /version\/((\d+)(\.(\d+))(\.\d+)*)/.test(ua) then " " + o + RegExp.$2 + " " + o + RegExp.$2 + "_" + RegExp.$4 else ((if /opera(\s|\/)(\d+)\.(\d+)/.test(ua) then " " + o + RegExp.$2 + " " + o + RegExp.$2 + "_" + RegExp.$3 else "")))) else (if is_("konqueror") then "konqueror" else (if is_("blackberry") then (b + ((if /Version\/(\d+)(\.(\d+)+)/i.test(ua) then " " + b + RegExp.$1 + " " + b + RegExp.$1 + RegExp.$2.replace(".", "_") else ((if /Blackberry ?(([0-9]+)([a-z]?))[\/|;]/g.test(ua) then " " + b + RegExp.$2 + ((if RegExp.$3 then " " + b + RegExp.$2 + RegExp.$3 else "")) else ""))))) else (if is_("android") then (a + ((if /Version\/(\d+)(\.(\d+))+/i.test(ua) then " " + a + RegExp.$1 + " " + a + RegExp.$1 + RegExp.$2.replace(".", "_") else "")) + ((if /Android (.+); (.+) Build/i.test(ua) then " " + d + ((RegExp.$2).replace(RegExp(" ", "g"), "_")).replace(/-/g, "_") else ""))) else (if is_("chrome") then w + " " + c + ((if /chrome\/((\d+)(\.(\d+))(\.\d+)*)/.test(ua) then " " + c + RegExp.$2 + ((if (RegExp.$4 > 0) then " " + c + RegExp.$2 + "_" + RegExp.$4 else "")) else "")) else (if is_("iron") then w + " iron" else (if is_("applewebkit/") then (w + " " + s + ((if /version\/((\d+)(\.(\d+))(\.\d+)*)/.test(ua) then " " + s + RegExp.$2 + " " + s + RegExp.$2 + RegExp.$3.replace(".", "_") else ((if RegExp(" Safari\\/(\\d+)", "i").test(ua) then ((if (RegExp.$1 is "419" or RegExp.$1 is "417" or RegExp.$1 is "416" or RegExp.$1 is "412") then " " + s + "2_0" else (if RegExp.$1 is "312" then " " + s + "1_3" else (if RegExp.$1 is "125" then " " + s + "1_2" else (if RegExp.$1 is "85" then " " + s + "1_0" else ""))))) else ""))))) else (if is_("mozilla/") then g else ""))))))))))) ]

      getIpadApp: ->
        is_ = userAgent.is
        [ (if (is_("ipad|iphone|ipod") and not is_("safari")) then "ipad_app" else "") ]

      getLang: ->
        ua = userAgent.ua
        [ (if /[; |\[](([a-z]{2})(\-[a-z]{2})?)[)|;|\]]/i.test(ua) then ("lang_" + RegExp.$2).replace("-", "_") + ((if RegExp.$3 isnt "" then (" " + "lang_" + RegExp.$1).replace("-", "_") else "")) else "") ]

    screenInfo =
      width: (window.outerWidth or document.documentElement.clientWidth) - 15
      height: window.outerHeight or document.documentElement.clientHeight
      screens: [ 0, 768, 980, 1200 ]
      screenSize: ->
        screenInfo.width = (window.outerWidth or document.documentElement.clientWidth) - 15
        screenInfo.height = window.outerHeight or document.documentElement.clientHeight
        screens = screenInfo.screens
        i = screens.length
        array = []
        maxw = undefined
        minw = undefined
        while i--
          if screenInfo.width >= screens[i]
            array.push "minw_" + screens[(i)]  if i
            array.push "maxw_" + (screens[(i) + 1] - 1)  if i <= 2
            break
        array

      getOrientation: ->
        (if screenInfo.width < screenInfo.height then [ "orientation_portrait" ] else [ "orientation_landscape" ])

      getInfo: ->
        array = []
        array = array.concat(screenInfo.screenSize())
        array = array.concat(screenInfo.getOrientation())
        array

      getPixelRatio: ->
        array = []
        pixelRatio = (if window.devicePixelRatio then window.devicePixelRatio else 1)
        if pixelRatio > 1
          array.push "retina_" + parseInt(pixelRatio) + "x"
          array.push "hidpi"
        else
          array.push "no-hidpi"
        array

    dataUriInfo =
      data: new Image()
      div: document.createElement("div")
      isIeLessThan9: false
      getImg: ->
        dataUriInfo.data.src = "data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///ywAAAAAAQABAAACAUwAOw=="
        dataUriInfo.div.innerHTML = "<!--[if lt IE 9]><i></i><![endif]-->"
        dataUriInfo.isIeLessThan9 = dataUriInfo.div.getElementsByTagName("i").length is 1
        dataUriInfo.data

      checkSupport: ->
        if dataUriInfo.data.width isnt 1 or dataUriInfo.data.height isnt 1 or dataUriInfo.isIeLessThan9
          [ "no-datauri" ]
        else
          [ "datauri" ]

    selector_n = selector_n or ""
    selector navigator.userAgent, selector_n

    _ua = userAgent.getBrowser().join(" ")
    window.browserType = _ua.split(/\s/)

    _pl = userAgent.getPlatform().join(" ")
    window.smartphoneType = _pl.split(/\s/)

    _mo = userAgent.getMobile().join(" ")
    window.mobileType = _mo.split(/\s/)

module.exports = Selector