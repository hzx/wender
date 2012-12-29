

class ns.ObservableList

  constructor: ->
    @list = ns.List()
    @insertObservable = ns.Observable
    @deleteObservable = ns.Observable

  addInsertListener: (listener) ->
    @insertObservable.addListener(listener)

  removeInsertListener: (listener) ->
    @insertObservable.removeListener(listener)

  addDeleteListener: (listener) ->
    @deleteObservable.addListener(listener)

  removeDeleteListener: (listener) ->
    @deleteObservable.removeListener(listener)

  notifyInsert: (obj, beforeId) ->
    for hsh, listener in @insertObservable
      listener(obj, beforeId)

  notifyDelete: (obj) ->
    for hsh, listener in @deleteObservable
      listener(obj)

  insert: (obj) ->
    node = @list.insert(obj)
    beforeId = if node.nextNode isnt null
      node.nextNode.obj.id
    else
      null
    @notifyInsert(obj, beforeId)

  insertNode: (node) ->
    @list.insertNode(node)
    beforeId = if node.nextNode isnt null
      node.nextNode.obj.id
    else
      null
    @notifyInsert(node.obj, beforeId)

  append: (obj) ->
    node = @list.append(obj)
    @notifyInsert(obj, null)

  appendNode: (node) ->
    @list.appendNode(node)
    @notifyInsert(node.obj, null)

  insertAfter: (obj, id) ->
    node = @list.insertAfter(obj, id)
    beforeId = if node.nextNode isnt null
      node.nextNode.obj.id
    else
      null
    @notifyInsert(obj, beforeId)

  insertAfterNode: (node, id) ->
    beforeId = if node.nextNode isnt null
      node.nextNode.obj.id
    else
      null
    @notifyInsert(node.obj, beforeId)

  insertBefore: (obj, id) ->
    node = @list.insertBefore(obj, id)
    beforeId = if node.nextNode isnt null
      node.nextNode.obj.id
    else
      null
    @notifyInsert(obj, beforeId)

  insertBeforeNode: (node, id) ->
    @list.insertBeforeNode(node, id)
    beforeId = if node.nextNode isnt null
      node.nextNode.obj.id
    else
      null
    @notifyInsert(node.obj, beforeId)

  getNodeById: (id) ->
    @list.getNodeById(id)

  getById: (id) ->
    @list.getById(id)

  deleteById: (id) ->
    node = @list.deleteById(id)
    if node isnt null
      @notifyDelete(node.obj)

  forEach: (func) ->
    @list.forEach(func)

  filter: (func) ->
    @list.filter(func)

