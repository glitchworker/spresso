getTime = ->

  arr = new Array('日', '月', '火', '水', '木', '金', '土')
  now = new Date

  year = now.getFullYear()
  getMonth = now.getMonth() + 1
  month = ('0' + getMonth).slice(-2)
  date = ('0' + now.getDate()).slice(-2)
  day = now.getDay()
  hours = ('0' + now.getHours()).slice(-2)
  minutes = ('0' + now.getMinutes()).slice(-2)
  seconds = ('0' + now.getSeconds()).slice(-2)

  dates = year + '年' + month + '月' + date + '日'
  days = arr[day] + '曜日'
  times = hours + '時' + minutes + '分' + seconds + '秒'

  str = dates + ' ' + days + ' ' + times

  return String(str)

module.exports = getTime