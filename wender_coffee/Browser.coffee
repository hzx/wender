

class ns.Browser

  constructor: ->
    @ids = {}
    @body = new ns.DomElement('div', {}, [], null, null)
    @body.node = document.body
    @router = new ns.Router()
    @statistic = new ns.Statistic()

    # subscribe to router.urlChange
    @router.url.addListener(this.onRouterUrlChange)

  loadScript: (url, callback) ->
    script = document.createElement("script")
    script.type = "text/javascript"

    if script.readyState
      script.onreadystatechange = ->
        if script.readyState is "loaded" or script.readyState is "complete"
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
      throw Error('element with id "' + id + '" already exists')
    @ids[id] = element

  removeIdElement: (id) ->
    if not (id of @ids)
      throw Error('element with id "' + id + '" not exists')
    delete @ids[id]

  setTitle: (text) ->
    document.title = text

  appendElement: (element) ->
    @body.append(element)
    element.enterDocument()

  removeElement: (element) ->
    element.exitDocument()
    @body.removeChild(element)

  # common methods
  
  addTimeoutWork: (work, time) ->
    id = window.setTimeout(work, time)
    work.hash = id

  removeTimeoutWork: (work) ->
    window.clearTimeout(work.hash)
    delete work.hash

  addRender: (render, time) ->
    id = window.setInterval(render, time)
    render.hash = id

  removeRender: (render) ->
    window.clearInterval(render.hash)
    delete render.hash

  # events

  onRouterUrlChange: (oldValue, newValue) =>
    @statistic.track('Source', 'Visit', newValue)
