

class ns.World extends ns.OrmStruct

  constructor: ->

  load: (callback) ->
    ns.orm.load(callback)

  validate: (obj) ->
    ns.orm.validate(ob)

  getImageUrl: (filename) ->
    '/static/img/' + filename.value
