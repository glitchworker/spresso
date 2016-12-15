class Common

  @getName: (str) ->
    document.querySelector('body.page-' + str.toLowerCase())

module.exports = Common