

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
    # for rmap binded object
    @obj = null

  getNode: ->
    return @node

  getHash: ->
    @hash

  # manipulate DOM
  
  remove: ->
    @parent.removeChild(this)

  removeRaw: ->
    if @isInDocument
      @exitDocument()
    if !!@node.parentNode
      @node.parentNode.removeChild(@node)

  # private

  enterDocument: ->
    @isInDocument = true

  exitDocument: ->
    @isInDocument = false

  # TODO(dem) move to detect features, use function
  fireClick: ->
    # for firefox browsers
    if !! @node.click
      @node.click()
      return

    # for other browsers
    if (document.createEvent)
      event = document.createEvent("MouseEvents")
      event.initMouseEvent("click", true, true, window,
          0, 0, 0, 0, 0, false, false, false, false, 0, null)
      @node.dispatchEvent(event)
    else
      @node.fireEvent('onclick', @node.ownerDocument.createEventObject())
