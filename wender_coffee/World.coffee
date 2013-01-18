

class ns.World

  constructor: ->

  load: (callback) ->
    ns.orm.load(callback)

  getImageUrl: (filename) ->
    '/static/img/#{filename}'
