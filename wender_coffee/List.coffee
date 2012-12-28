

class ns.ListNode

  constructor: (obj) ->
    @obj = obj
    @nextNode = null
    @prevNode = null


class ns.List

  constructor: ->
    @nodes = {}
    @firstNode = null
    @lastNode = null
    @count = 0

  insert: (obj) ->
    node = ListNode(obj)
    @insertNode(node)
    node

  insertNode: (node) ->
    @count = @count + 1
    @nodes[node.obj.id] = node
    if @firstNode is null
      @firstNode = node
      @lastNode = node
    else
      node.nextNode = @firstNode
      @firstNode.prevNode = node
      @firstNode = node

  append: (obj) ->
    node = ListNode(obj)
    @appendNode(node)
    node

  appendNode: (node) ->
    @nodes[node.obj.id] = node
    @count = @count + 1
    if @lastNode is null
      @lastNode = node
      @firstNode = node
    else
      node.prevNode = @lastNode
      @lastNode.nextNode = node
      @lastNode = node

  insertAfter: (obj, id) ->
    node = ListNode(obj)
    @insertAfterNode(node, id)
    node

  insertAfterNode: (node, id) ->
    if id of @nodes
      @nodes[node.obj.id] = node
      @count = @count + 1
      idNode = @nodes[id]
      if idNode.nextNode isnt null
        idNode.nextNode.prevNode = node
        node.nextNode = idNode.nextNode
      else
        @lastNode = node
      idNode.nextNode = node
      node.prevNode = idNode

  insertBefore: (obj, id) ->
    node = ListNode(obj)
    @insertBeforeNode(node, id)
    node

  insertBeforeNode: (node, id) ->
    if id of @nodes
      @nodes[node.obj.id] = node
      @count = @count + 1
      idNode = @nodes[id]
      if idNode.prevNode isnt null
        idNode.prevNode.nextNode = node
        node.prevNode = idNode.prevNode
      else
        @firstNode = node
      idNode.prevNode = node
      node.nextNode = idNode

  getNodeById: (id) ->
    if id of @nodes
      @nodes[id]
    else
      null

  getById: (id) ->
    node = @getNodeById(id)
    if node isnt null
      node.obj
    else
      null

  deleteById: (id) ->
    if id of @nodes
      node = @nodes[id]
      if node.nextNode isnt null
        node.nextNode.prevNode = node.prevNode
      else
        @lastNode = node.prevNode
      if node.prevNode isnt null
        node.prevNode.nextNode = node.nextNode
      else
        @firstNode = node.nextNode
      if @lastNode is node.prevNode
        @lastNode.nextNode = null
      if @firstNode is node.nextNode
        @firstNode.prevNode = null
      delete @nodes[id]
      node.nextNode = null
      node.prevNode = null
      @count = @count - 1
      node
    else
      null

  forEach: (func) ->
    cursor = @firstNode
    while cursor isnt null
      func(cursor.obj)
      cursor = cursor.nextNode

  filter: (func) ->
    filtered = List()
    cursor = @firstNode
    while cursor isnt null
      if func(cursor.obj)
        filtered.append(cursor.obj)
      cursor = cursor.nextNode
    filtered

