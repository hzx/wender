

createXhr = null

initCreateXhr = ->
  methods = [
    -> new XMLHttpRequest(),
    -> new ActiveXObject("Msxml2.XMLHTTP"),
    -> new ActiveXObject("Microsoft.XMLHTTP")
  ]
  for method in methods
    try
      method()
    catch e
      continue
    createXhr = method
    break
  if createXhr is null
    throw "Not create xhr"


initNet = ->
  initCreateXhr()


class ns.Net
  maxOpenXhr: 8

  constructor: ->

  # TODO(dem) rework this to support multiple xhrs
  getFreeXhr: ->
    createXhr()

  # TODO(dem) add stream
  # get: (url, success, fail, stream) ->
  get: (url, success, fail) ->
    xhr = @getFreeXhr()
    # TODO(dem) place onreadystatechange method
    xhr.onreadystatechange = =>
    nocacheUrl = url + (if (/\?/).test(url) then "&" else "?") + (new Date()).getTime()
    xhr.open("GET", nocacheUrl, true)
    xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest')
    xhr.send(null)

  # TODO(dem) add stream
  # post: (url, data, success, fail, stream) ->
  post: (url, data, success, fail) ->
    xhr = @getFreeXhr()
    # TODO(dem) place onreadystatechange method
    xhr.onreadystatechange = =>
    xhr.open("POST", url, true)
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded')
    xhr.setRequestHeader('Content-Length', data.length)
    xhr.send(data)

