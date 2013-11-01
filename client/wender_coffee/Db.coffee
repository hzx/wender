
class ns.Db

  serializeWhere_: (where) ->
    return JSON.stringify(where)


  serializeValues_: (values) ->
    return JSON.stringify(values)

  insert: (coll, values) ->
    data = {
      'op': 'insert',
      'coll': coll,
      'values': @serializeValues_(values)
    }
    # ns.net.post('/o', data, () ->
    # , () ->
    # )

  find: (dest, coll, where) ->
    data = {
      'op': 'find',
      'coll': coll,
      'where': @serializeWhere_(where)
    }
    # me = this
    # ns.net.post('/o', data, (response) ->
    # , (status) ->
    # )

  update: (coll, where, values) ->
    data = {
      'op': 'update',
      'coll': coll,
      'where': @serializeWhere_(where),
      'values': @serializeValues_(values)
    }
    # ns.net.post('/o', data, () ->
    # , () ->
    # )

  remove: (coll, where) ->
    data = {
      'op': 'remove',
      'coll': coll,
      'where': @serializeWhere_(where)
    }

  bunchInsert: (inserts) ->

  bunchFind: (finds) ->

  bunchUpdate: (updates) ->

  bunchRemove: (removes) ->
