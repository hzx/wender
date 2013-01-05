

# TODO(dem) reimplement NODE without List
class ns.DomElement extends ns.DomNode
  kind: 'element'
  eventNamePattern: /^on([a-z]+)/i

  # Params:
  #   name - tagName
  #   attributes - dictionary of attribute name, value
  #   childs - array of DomElement or DomText
  #   list - ObservableList where stored data
  #   render - render item from ObservableList
  constructor: (name, attributes, childs, list, render) ->
    super()

    @name = name

    # for reactive behavior
    @list = list
    @render = render
    # store here obj id to child
    @objChilds = {}

    @id = null 
    @events = {}

    # create dom element
    @node = document.createElement(name)

    # childs
    @hashGenerator = new ns.HashGenerator()
    # @childs = new ns.List()
    @childs = {}
    @first = null
    @last = null

    # class list
    @classList = {}

    # add childs
    for child in childs
      @append(child)

    @setAttributes(attributes)

  setAttributes: (attributes) ->
    for name, value of attributes
      if name is 'id'
        @setId(value)
        continue
      if name is 'class'
        for cn in value
          @addClass(cn)
        continue
      # TODO(dem) need style attribute
      # if name is 'style'
      # events
      if ns.isIe
        @events[name] = value
        continue
      else
        eventMatch = @eventNamePattern.exec(name)
        if eventMatch isnt null
          shortName = eventMatch[1]
          @events[shortName] = value
          continue
      throw "unknown attribute name '" + name + "'"

  # manipulate DOM
  
  # register id in browser
  registerId: ->
    if @id isnt null
      ns.browser.addIdElement(@id, this)

  # unregister id in browser
  unregisterId: ->
    if @id isnt null
      ns.browser.removeIdElement(@id)

  setId: (id) ->
    # unregister old id
    if @isInDocument and @id isnt null
      @unregisterId(id)
    @id = id
    @node.id = id
    # register id
    if @isInDocument
      @registerId(id, @node)

  # internal method
  classListToString: ->
    cn = ''
    cn = cn + name + ' ' for name of @classList
    @node.className = cn

  addClass: (name) ->
    unless name of @classList
      @classList[name] = null
      @classListToString()

  removeClass: (name) ->
    if name of @classList
      delete @classList[name]
      @classListToString()

  hasClass: (name) ->
    name of @classList

  prepareNode: (node) ->
    node.parent = this
    node.hash = @hashGenerator.generate()
    # add to obj id to childs node map
    if node.obj isnt null
      @objChilds[node.obj.getHash()] = node

  postAddNode: (node) ->
    # add node to childs
    @childs[node.hash] = node

    # listen events
    if @isInDocument
      node.enterDocument()

  insert: (node) ->
    @prepareNode(node)

    # insert to begin in empty childs
    if @first is null
      # add to document
      @node.appendChild(node.node)

      @first = node
      @last = node
    else # insert before first
      # add to document
      @node.insertBefore(node.node, @first.node)

      @first.prev = node
      node.next = @first
      @first = node

    @postAddNode(node)

  append: (node) ->
    @prepareNode(node)

    # insert to end in empty childs
    if @last is null
      @first = node
      @last = node
    else # insert after last
      @last.next = node
      node.prev = @last
      @last = node

    # add to document
    @node.appendChild(node.node)

    @postAddNode(node)

  insertBefore: (node, before) ->
    if before is null
      @append(node)
    else
      # insert to begin
      if before.prev is null
        @insert(node)
      else # insert between two nodes
        @prepareNode(node)

        # add to document
        @node.insertBefore(node.node, before.node)

        # link refs
        before.prev.next = node
        node.prev = before.prev
        before.prev = node
        node.next = before

        @postAddNode(node)

  insertAfter: (node, after) ->
    if after is null
      @append(node)
    else
      if after.next is null
        @append(node)
      else # insert between two nodes
        @prepareNode(node)

        # add to document
        @node.insertBefore(node.node, after.next.node)

        # link refs
        after.next.prev = node
        node.next = after.next
        after.next = node
        node.prev = after

        @postAddNode(node)

  removeChild: (node) ->
    if @isInDocument
      node.exitDocument()

    # remove from document
    @node.removeChild(node.node)

    # move right refs 
    if node.next isnt null
      node.next.prev = node.prev
    else
      @last = node.prev

    # move left refs
    if node.prev isnt null
      node.prev.next = node.next
    else
      @first = node.next

    # unlink all refs
    node.parent = null
    node.next = null
    node.prev = null
    # removed node must have hash == null
    node.hash = null

    if node.obj isnt null
      delete @objChilds[node.obj.getHash()]

    delete @childs[node.hash]

  empty: ->
    while @first isnt null
      @removeChild(@first)

  forEachChild: (func) ->
    cursor = @first
    while cursor isnt null
      func(cursor)
      cursor = cursor.next

  addEvent: (name, handler) ->
    ns.addEvent(@node, name, @onEvent)

  removeEvent: (name, handler) ->
    ns.removeEvent(@node, name, @onEvent)

  # private

  enterDocument: ->
    # listen events
    for name, handler of @events
      @addEvent(name, handler)

    @registerId()

    # listen list changes
    if @list?
      @list.addInsertListener(@onListInsert)
      @list.addDeleteListener(@onListDelete)
      # add childs
      @list.forEach (item) =>
        @onListInsert(item, null)

    # enterDocument for childs
    @forEachChild (child) ->
      child.enterDocument()

    super()

  exitDocument: ->
    # unlisten events
    for name, handler of @events
      @removeEvent(name, handler)

    @unregisterId()

    # unlisten list changes
    if @list?
      @list.removeInsertListener(@onListInsert)
      @list.removeDeleteListener(@onListDelete)
      # remove childs
      @list.forEach (item) =>
        @onListDelete(item)

    # exitDocument for childs
    @forEachChild (child) ->
      child.exitDocument()

    super()

  # events
  
  onListInsert: (obj, before) =>
    node = @render(obj)
    node.obj = obj
    if before isnt null
      @insertBefore(node, before)
    else
      @append(node)

  onListDelete: (obj) =>
    if obj.getHash() of @objChilds
      node = @objChilds[obj.getHash()]
      @removeChild(node)

  # event wrapper
  onEvent: (event) =>
    event = event || window.event
    target = event.target || event.srcElement

    handler = @events[event.type]
    # TODO(dem) make more specific params depending on event type
    handler({'type': event.type, 'event': event, 'element': this, 'target': target })
