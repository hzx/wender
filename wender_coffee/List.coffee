

class ns.ListNode

  constructor: (obj) ->
    @obj = obj
    @next = null
    @prev = null


class ns.List

  constructor: ->
    @nodes = {}
    @first = null
    @last = null
    @count = 0

  insert: (obj) ->
    node = new ns.ListNode(obj)
    @count = @count + 1
    @nodes[node.obj.getHash()] = node
    if @first is null
      @first = node
      @last = node
    else
      node.next = @first
      @first.prev = node
      @first = node
    node

  append: (obj) ->
    node = new ns.ListNode(obj)
    @nodes[node.obj.getHash()] = node
    @count = @count + 1
    if @last is null
      @last = node
      @first = node
    else
      node.prev = @last
      @last.next = node
      @last = node
    node

  insertAfter: (obj, afterObj) ->
    node = new ns.ListNode(obj)
    if afterObj.getHash() of @nodes
      @nodes[obj.getHash()] = node
      @count = @count + 1
      after = @nodes[afterObj.getHash()]
      if after.next isnt null
        after.next.prev = node
        node.next = after.next
      else
        @last = node
      after.next = node
      node.prev = after
    node

  insertBefore: (obj, beforeObj) ->
    node = new ns.ListNode(obj)
    if beforeObj.getHash() of @nodes
      @nodes[obj.getHash()] = node
      @count = @count + 1
      before = @nodes[beforeObj.getHash()]
      if before.prev isnt null
        before.prev.next = node
        node.prev = before.prev
      else
        @first = node
      before.prev = node
      node.next = before
    node

  get: (hash) ->
    if hash of @nodes
      @nodes[hash].obj
    else
      null

  # TODO(dem) fix bug
  remove: (hash) ->
    if hash of @nodes
      node = @nodes[hash]

      if node.next isnt null
        node.next.prev = node.prev
      else
        @last = node.prev

      if node.prev isnt null
        node.prev.next = node.next
      else
        @first = node.next

      if @last isnt null and @last is node.prev
        @last.next = null
      if @first isnt null and @first is node.next
        @first.prev = null

      delete @nodes[hash]
      node.next = null
      node.prev = null
      @count = @count - 1

      node.obj
    else
      null

  forEach: (func) ->
    cursor = @first
    while cursor isnt null
      func(cursor.obj)
      cursor = cursor.next

  filter: (func) ->
    filtered = List()
    cursor = @first
    while cursor isnt null
      if func(cursor.obj)
        filtered.append(cursor.obj)
      cursor = cursor.next
    filtered

