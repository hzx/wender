

class ns.ObservableList extends ns.List

  constructor: ->
    super()
    @insertObservable = new ns.Observable()
    @deleteObservable = new ns.Observable()

  addInsertListener: (listener) ->
    @insertObservable.addListener(listener)

  removeInsertListener: (listener) ->
    @insertObservable.removeListener(listener)

  addDeleteListener: (listener) ->
    @deleteObservable.addListener(listener)

  removeDeleteListener: (listener) ->
    @deleteObservable.removeListener(listener)

  notifyInsert: (obj, beforeObj) ->
    for hash, listener of @insertObservable.listeners
      listener(obj, beforeObj)

  notifyDelete: (obj) ->
    for hash, listener of @deleteObservable.listeners
      listener(obj)

  insert: (obj) ->
    node = super(obj)
    before = if node.next isnt null
      node.next.obj
    else
      null
    @notifyInsert(obj, before)

  append: (obj) ->
    node = super(obj)
    @notifyInsert(obj, null)

  insertAfter: (obj, afterObj) ->
    node = super(obj, afterObj)
    before = if node.next isnt null
      node.next.obj
    else
      null
    @notifyInsert(obj, before)

  insertBefore: (obj, beforeObj) ->
    node = super(obj, beforeObj)
    @notifyInsert(obj, beforeObj)

  remove: (hash) ->
    removed = super(hash)
    if removed isnt null
      @notifyDelete(removed)
