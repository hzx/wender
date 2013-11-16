

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

    @events = {}

    @id = null
    @data = null
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

  getChildsCount: ->
    count = 0
    for hash of @childs
      count = count + 1
    return count

  setText: (text) ->
    ns.setText(@node, text)
    # @node.innerText = text

  setAttribute: (name, value) ->
    @node.setAttribute(name, value)

  removeAttribute: (name) ->
    @node.removeAttribute(name)

  getAttribute: (name) ->
    if name is 'value'
      return @node.value
    return @node.getAttribute(name)

  setAttributes: (attributes) ->
    for name, value of attributes
      if name is 'id'
        @setId(value)
        continue
      if name is 'class'
        for cn in value
          @addClass(cn)
        continue
      if name is 'obj'
        @obj = value
        continue
      if name is 'data'
        @data = value
        continue
      if name is 'value'
        @node.value = value

      if name is 'style'
        for sname, svalue of value
          @setStyle(sname, svalue)
        continue
      
      # events
      eventMatch = @eventNamePattern.exec(name)
      # we have event attribute
      if eventMatch isnt null
        shortName = eventMatch[1]
        @events[shortName] = value
        continue

      # other values
      @setAttribute(name, value)


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

  emptyClasses: ->
    @classList = {}
    @classListToString()

  toggleClass: (name) ->
    if @hasClass(name)
      @removeClass(name)
    else
      @addClass(name)

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
      @node.appendChild(node.getNode())

      @first = node
      @last = node
    else # insert before first
      # add to document
      @node.insertBefore(node.getNode(), @first.getNode())

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
    @node.appendChild(node.getNode())

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
        @node.insertBefore(node.getNode(), before.getNode())

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
        @node.insertBefore(node.getNode(), after.next.getNode())

        # link refs
        after.next.prev = node
        node.next = after.next
        after.next = node
        node.prev = after

        @postAddNode(node)

  getChild: (hash) ->
    return @objChilds[hash]

  removeChild: (node) ->
    if @isInDocument
      node.exitDocument()

    # remove from document
    @node.removeChild(node.getNode())

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
    next = null
    while cursor isnt null
      next = cursor.next
      func(cursor)
      cursor = next

  addEvent: (name, handler) ->
    @events[name] = handler
    ns.addEvent(@node, name, @onEvent)

  removeEvent: (name, handler) ->
    if name of @events
      delete @events[name]
    ns.removeEvent(@node, name, @onEvent)

  # private

  enterDocument: ->
    if @isInDocument
      return null

    # listen events
    for name, handler of @events
      ns.addEvent(@node, name, @onEvent)

    @registerId()

    # unlisten obj hash change
    if @obj isnt null
      @obj.addHashListener(@onObjHashChange)

    # listen list changes
    if @list isnt null
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
    if @isInDocument is false
      return null

    # unlisten events
    for name, handler of @events
      ns.removeEvent(@node, name, @onEvent)

    @unregisterId()

    # unlisten obj hash change
    if @obj isnt null
      @obj.removeHashListener(@onObjHashChange)

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

  # style

  getWidth: ->

  getHeight: ->

  # Get a style property (name) of a specific element (elem)
  getStyle: (name) ->
    # if the property exists in style[], then it's been set
    # recently (and is current)
    if @node.style[name]
      return @node.style[name]

    # Otherwise, try to use IE's method
    else if @node.currentStyle
      return @node.currentStyle[name]

    # Or the W3C's method, if it exists
    else if document.defaultView and document.defaultView.getComputedStyle
      # It uses the traditional 'text-align' style of rule writing,
      # instead of textAlign
      name = name.replace(/[A-Z]/g, "-$1")
      name = name.toLowerCase()

      # Get the style object and get the value of the property (if it exists)
      s = document.defaultView.getComputedStyle(@node, "")
      return s and s.getPropertyValue(name)
    # Otherwise, we're using some other browser
    else
      return null

  setStyle: (name, value) ->
    @node.style[name] = value

  updateChildHash: (oldhash, newhash) ->
    if not (oldhash of @objChilds)
      return

    # move node of objChilds from old to new
    child = @objChilds[oldhash]
    delete @objChilds[oldhash]
    @objChilds[newhash] = child

  # events

  onObjHashChange: (oldValue, newValue) =>
    if @parent isnt null
      @parent.updateChildHash(oldValue, newValue)
  
  onListInsert: (obj, before) =>
    node = @render(obj)
    node.obj = obj
    if before isnt null
      # beforeNode = @objChilds[before.getHash()]
      beforeNode = @objChilds[before]
      @insertBefore(node, beforeNode)
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

    if !!handler is false
      return false
      # console.log('undefined handler for event.type "' + event.type + '"')

    # TODO(dem) make more specific params depending on event type
    isPreventDefault = handler({
      'type': event.type,
      'event': event,
      'element': this,
      'target': target
    })

    # stop event propagation (bubbling)
    if isPreventDefault is false
      ns.stopPropagation(event)
      ns.preventDefault(event)

