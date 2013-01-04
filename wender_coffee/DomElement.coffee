

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
    @list = list
    @render = render

    @id = null 
    @events = {}

    # create dom element
    @node = document.createElement(name)

    # childs
    @hashGenerator = new ns.HashGenerator()
    @childs = new ns.List()
    # store here obj id to child
    @objChilds = {}

    # for rmap
    @obj = null

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
      # events
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
    if @isInDocument and (@id isnt null)
      @unregisterId(id)
    @id = id
    @node.id = id
    # register id
    if @isInDocument
      @registerId(id, @node)

  # internal method
  classListToString: ->
    cn = ''
    cn = cn + ' ' + name for name of @classList
    @node.className = cn

  addClass: (name) ->
    if not (name of @classList)
      @classList[name] = null
      @classListToString()

  removeClass: (name) ->
    if name of @classList
      delete @classList[name]
      @classListToString()

  prepareNode: (node) ->
    node.parent = this
    node.hash = @hashGenerator.generate()
    # add to obj id to childs map
    if node.obj isnt null
      @objChilds[node.hash] = node

  insert: (node) ->
    @prepareNode(node)
    @childs.insert(node)
    if @isInDocument
      node.enterDocument()

  append: (node) ->
    @prepareNode(node)
    @childs.insert(node)
    # add to document
    @node.appendChild(node.node)
    # listen events
    if @isInDocument
      node.enterDocument()

  insertBefore: (node, beforeNode) ->
    @prepareNode(node)
    @childs.insertBefore(node, beforeNode)
    # add to document
    @node.insertBefore(node.node, beforeNode.node)
    # listen events
    if @isInDocument
      node.enterDocument()

  insertAfter: (node, afterNode) ->
    @prepareNode(node)
    @childs.insertAfter(node, afterNode)
    # add to document
    @node.insertBefore(node.node, afterNode.next.node)
    # listen events
    if @isInDocument
      node.enterDocument()

  removeChild: (node) ->
    removed = @childs.remove(node.getHash())
    if removed isnt null
      # update first and last
      @first = @childs.first.obj
      @last = @childs.last.obj
      removed.parent = null
      removed.hash = null
      # remove from obj id to child map
      if removed.obj isnt null and removed.obj.getHash() of @objChilds
        delete @objChilds[removed.obj.getHash()]
      # unlisten events
      if @isInDocument
        removed.exitDocument()
      # remove from document
      @node.removeChild(removed.node.hash)

  addEvent: (name, handler) ->
    ns.addEvent(@node, name, handler)

  removeEvent: (name, handler) ->
    ns.removeEvent(@node, name, handler)

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

    # enterDocument for childs
    @childs.forEach (child) ->
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

    # exitDocument for childs
    @childs.forEach (child) ->
      child.exitDocument()

    super()

  # events
  
  onListInsert: (obj, beforeId) =>
    node = @render(obj)
    node.obj = obj
    if beforeId isnt null and beforeId of @objChilds
      before = @objChilds[beforeId]
      @insertBefore(node, before)
    else
      @append(node)

  onListDelete: (obj) =>
    if obj.getHash() of @objChilds
      node = @objChilds[obj.getHash()]
      @removeChild(node)

