

class ns.DomNode

  constructor: ->
    # for dom
    @node = null
    @parent = null
    @next = null
    @prev = null
    # for list
    @hash = null
    # for enter/exitDocument
    @isInDocument = false

  getHash: ->
    @hash

  # manipulate DOM
  
  remove: ->
    @parent.removeChild(this)

  # private

  enterDocument: ->
    @isInDocument = true

  exitDocument: ->
    @isInDocument = false

