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

module.exports = Common