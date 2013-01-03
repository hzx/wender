

class ns.ObservableList

  constructor: ->
    @list = ns.List()
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
    for hash, listener in @insertObservable
      listener(obj, beforeObj)

  notifyDelete: (obj) ->
    for hash, listener in @deleteObservable
      listener(obj)

  insert: (obj) ->
    node = @list.insert(obj)
    before = if node.next isnt null
      node.next.obj
    else
      null
    @notifyInsert(obj, before)

  append: (obj) ->
    node = @list.append(obj)
    @notifyInsert(obj, null)

  insertAfter: (obj, afterObj) ->
    node = @list.insertAfter(obj, afterObj)
    before = if node.next isnt null
      node.next.obj
    else
      null
    @notifyInsert(obj, before)

  insertBefore: (obj, beforeObj) ->
    node = @list.insertBefore(obj, beforeObj)
    @notifyInsert(obj, beforeObj)

  get: (hash) ->
    @list.get(hash)

  remove: (hash) ->
    removed = @list.remove(hash)
    if removed isnt null
      @notifyDelete(removed)

  forEach: (func) ->
    @list.forEach(func)

  filter: (func) ->
    @list.filter(func)

