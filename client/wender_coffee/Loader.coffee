
###
Load resources css, js.
Show progress by progressCallback.
Run successCallback or failCallback.
###
class ns.Loader

  ###
  resources is array of [ url, css | js ]
  ###
  constructor: ->
    @resources = []

    @loaded = []

  load: (resources, success, fail) ->
    @resources = resources
    @success = success
    @fail = fail

    @buf = []

    for res in resources
      url = res[0]
      lr = new LoaderResource(url, @onSuccess, @onFail)
      @buf.push(lr)
      ns.net.getCached(url, lr.onSuccess, lr.onFail)

  process: ->
    for res in @resources
      kind = res[1]
      content = res[2]
      if kind is 'js'
        @createJs(content)
        continue
      if kind is 'css'
        @createCss(content)
        continue
    @success()


  createJs: (content) ->
    js = document.createElement('script')
    js.type = 'text/javascript'
    js.text = content
    document.getElementsByTagName("head")[0].appendChild(js)

  createCss: (content) ->
    css = document.createElement('style')
    css.type = 'text/css'
    if css.styleSheet
      css.styleSheet.cssText = content
    else
      css.appendChild(document.createTextNode(content))
    document.getElementsByTagName("head")[0].appendChild(css)

  onSuccess: (url, response) =>
    done = 0
    for res in @resources
      if (res.length is 3)
        done = done + 1
        continue

      if (res.length is 2) and (res[0] is url)
          res.push(response)
          done = done + 1

    if @resources.length is done
      @process()

  onFail: (url, status) =>
    @fail(status)

class LoaderResource
  constructor: (url, success, fail) ->
    @url = url
    @success = success
    @fail = fail

  onSuccess: (response) =>
    @success(@url, response)

  onFail: (status) =>
    @fail(@url, status)
