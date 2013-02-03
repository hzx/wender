

class ns.Router

  constructor: ->
    @enter()

  isRouterChangeUrl: false


  setPatterns: (patterns) ->
    # compile regex in 0 item
    compiled = []
    for pattern in patterns
      re = new RegExp(pattern[0], 'i')
      handler = pattern[1]
      name = pattern[2]
      compiled.push([re, handler, name])

    @urlpatterns = compiled

  enter: ->
    if "onhashchange" of window then ns.addEvent(window, 'hashchange', @onHashChange)

  exit: ->
    if "onhashchange" of window then ns.removeEvent(window, 'hashchange', @onHashChange)

  # Common methods

  _clarifyUrl: (url) ->
    url.replace(/^\s*([-\/\w]+)(?:[\/\s]*)$/gi, '$1')

  _patternToUrl: (pattern, args) ->
    pureRe = pattern[0].toString().replace(/^\/|[\^\\\$]|\/i$/gi, '')
    for arg in args
      pureRe = pureRe.replace(/\(.*\)/i, arg)
    pureRe
    
  _setWindowUrl: (pattern, args) ->
    @isRouterChangeUrl = true
    window.location.hash = @_patternToUrl(pattern, args)

  routePattern: (pattern, args) ->
    pattern[1](args...)

  init: ->
    # get url from window hash
    url = window.location.hash.replace(/^#(.*)\s*/gi, '$1')
    url = '/' if url.length is 0
    # route
    @routeUrl(url)

  routeByName: (name, args) ->
    unless args? then args = []
    for pattern in @urlpatterns
      if pattern[2]? and pattern[2] == name
        @_setWindowUrl(pattern, args)
        @routePattern(pattern, args)
        break

  routeUrl: (url) ->
    url = @_clarifyUrl(url)

    for pattern in @urlpatterns
      params = pattern[0].exec(url)
      if params is null then continue
      args = (params[1...params.length] if params.length >= 2) or []
      @routePattern(pattern, args)
      break

  # Events

  onRoute: (url) =>
    @routeUrl(url)
    

  onHashChange: (event) =>
    # if not @isRouterChangeUrl then @onRouteInit()
    if not @isRouterChangeUrl then @init()
    @isRouterChangeUrl = false

