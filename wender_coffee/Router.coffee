

class ns.Router

  constructor: ->
    @enter()

  isRouterChangeUrl: false


  setPatterns: (patterns) ->
    @patterns = patterns

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
    @onRoute(url)

  routeByName: (name, args) =>
    for pattern in @patterns
      if pattern[2]? and pattern[2] == name
        @_setWindowUrl(pattern, args)
        @routePattern(pattern, args)
        break

  # Events

  onRoute: (url) =>
    url = @_clarifyUrl(url)
    for pattern in @patterns
      params = pattern[0].exec(url)
      if params is null then continue
      args = (params[1...params.length] if params.length >= 2) or []
      @routePattern(pattern, args)
      break

  onHashChange: (event) =>
    if not @isRouterChangeUrl then @onRouteInit()
    @isRouterChangeUrl = false

