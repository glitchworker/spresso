getTimeStamp = ->

  now = new Date

  getYear = now.getFullYear().toString()
  year = getYear.substr(2, 2)
  getMonth = now.getMonth() + 1
  month = ('0' + getMonth).slice(-2)
  date = ('0' + now.getDate()).slice(-2)
  hours = ('0' + now.getHours()).slice(-2)
  minutes = ('0' + now.getMinutes()).slice(-2)
  seconds = ('0' + now.getSeconds()).slice(-2)

  dates = year + '' + month + '' + date
  times = hours + '' + minutes + '' + seconds

  str = dates + '' + times

  return String(str)

module.exports = getTimeStamp