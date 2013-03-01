

class ns.World extends ns.OrmStruct

  constructor: (type, name, parent) ->
    super(type, name, parent)

  load: (callback) ->
    ns.orm.load(this, callback)

  addStruct: (st) ->
    ns.orm.addStruct(st)

  validate: (obj) ->
    ns.orm.validate(ob)

  getImageUrl: (filename) ->
    if filename.value.length > 0
      '/static/img/' + filename.value
    else
      ''
