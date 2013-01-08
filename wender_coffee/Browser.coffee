

class ns.Browser

  constructor: ->
    @ids = {}
    @body = new ns.DomElement('div', {}, [], null, null)
    @body.node = document.body

  loadScript: (url, callback) ->
    script = document.createElement("script")
    script.type = "text/javascript"

    if script.readyState
      script.onreadystatechange = () ->
        if script.readyState == "loaded" or script.readyState == "complete"
          script.onreadystatechange = null
          callback()
    else
      script.onload = () ->
        callback()

    script.src = url
    document.getElementsByTagName("head")[0].appendChild(script)

  loadCss: (url) ->
    link = document.createElement('link')
    link.type = "text/css"
    link.rel = "stylesheet"
    link.href = url
    document.getElementsByTagName("head")[0].appendChild(link)

  getElementById: (id) ->
    if id of @ids
      @ids[id]
    else
      null

  addIdElement: (id, element) ->
    if id of @ids
      throw 'element with id "#{id}" already exists'
    @ids[id] = element

  removeIdElement: (id) ->
    if not (id of @ids)
      throw 'element with id "#{id}" not exists'
    delete @ids[id]

  setTitle: (text) ->
    window.title = text

  setUrl: (url) ->
    document.location.hash = url

  appendElement: (element) ->
    @body.append(element)
    element.enterDocument()

  removeElement: (element) ->
    element.exitDocument()
    @body.removeChild(element)

