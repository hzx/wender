

class ns.ObservableList extends ns.List

  constructor: ->
    super()
    @changeObservable = new ns.Observable()
    @insertObservable = new ns.Observable()
    @deleteObservable = new ns.Observable()

  addListener: (listener) ->
    @changeObservable.addListener(listener)

  removeListener: (listener) ->
    @changeObservable.removeListener(listener)

  addInsertListener: (listener) ->
    @insertObservable.addListener(listener)

  removeInsertListener: (listener) ->
    @insertObservable.removeListener(listener)

  addDeleteListener: (listener) ->
    @deleteObservable.addListener(listener)

  removeDeleteListener: (listener) ->
    @deleteObservable.removeListener(listener)

  notifyChange: (oldValue, newValue) ->
    for hash, listener of @changeObservable.listeners
      listener(oldValue, newValue)

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
    oldCount = @count
    node = super(obj)
    if oldCount isnt @count
      @notifyChange(oldCount, @count)
    @notifyInsert(obj, null)

  insertAfter: (obj, afterObj) ->
    oldCount = @count
    node = super(obj, afterObj)
    before = if node.next isnt null
      node.next.obj
    else
      null
    if oldCount isnt @count
      @notifyChange(oldCount, @count)
    @notifyInsert(obj, before)

  insertBefore: (obj, beforeObj) ->
    oldCount = @count
    node = super(obj, beforeObj)
    if oldCount isnt @count
      @notifyChange(oldCount, @count)
    @notifyInsert(obj, beforeObj)

  remove: (hash) ->
    oldCount = @count
    removed = super(hash)
    if removed isnt null
      if oldCount isnt @count
        @notifyChange(oldCount, @count)
      @notifyDelete(removed)
