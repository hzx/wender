

class ns.View

  constructor: ->
    # View members
    @element = null

    # DomNode implementation members
    @parent = null
    @next = null
    @prev = null
    @hash = null
    @isInDocument = false
    @obj = null

    @events = []

  # DomElement wrap methods

  addEvent: (observable, handler) ->
    @events.push([observable, handler])

  getNode: -> @element.getNode()

  getHash: -> @element.getHash()

  insert: (node) ->
    @element.insert(node)

  append: (node) ->
    @element.append(node)

  insertBefore: (node, before) ->
    @element.insertBefore(node, before)

  insertAfter: (node, after) ->
    @element.insertAfter(node, after)

  remove: ->
    @element.remove()

  enterDocument: ->
    # subscribe observables
    for event in @events
      event[0].addListener(event[1])
    
    @element.enterDocument();

  exitDocument: ->
    # unsubscribe observables
    for event in @events
      event[0].removeListener(event[1])
    
    @element.exitDocument()

  # View methods

  tryEnterDocument: ->
    if @isInDocument
      return false
    this.isInDocument = true
    return true

  tryExitDocument: ->
    if @isInDocument is false
      return false
    @isInDocument = false
    return true
