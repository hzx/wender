

# TODO(dem) need ObservableNode
class ns.DomNode

  constructor: () ->
    @hsh = null
    @childHsh = 0
    # parent node
    @parent = null
    # next siblings tag
    @next = null
    # previous siblings tag
    @prev = null
    # current node
    @node = null
    # tag childs
    # @childs = []
    @childs = {}
    @firstChild = null
    @lastChild = null

  isElement: ->
    return node.kind is 'element'

  # register id in browser
  registerId: (node) ->
    # if child element and contain id attribute then add it to browser ids
    if node.isElement() and ('id' of node.attributes)
      id = node.attributes['id']
      ns.browser.addIdElement(id, node)

  # unregister id in browser
  unregisterId: (node) ->
    if node.isElement() and ('id' of node.attributes)
      id = node.attributes['id']
      ns.browser.removeIdElement(id)

  append: (child) ->
    # add child.node to document
    @node.appendChild(child.node)

    # add to childs
    child.hsh = @childHsh
    @childs[@childHsh] = child
    @childHsh = @childHsh + 1

    # make parent to this
    child.parent = this

    @registerId(child)

    child.enterDocument()

  remove: ->
    @unregisterId(@node)

    if @parent isnt null
      @paremt.removeChild(this)
    else
      @node.parentNode.removeChild(@node)
    # remove child
    @exitDocument()

  removeChild: (child) ->
    @child.exitDocument()

    # remove from childs
    delete @childs[child.hsh]

    child.parent = null

    @unregisterId(@node)

    # remove child.node from document
    @node.parentNode.removeChild(@node)

  enterDocument: ->
    child.enterDocument() for child in @childs

  exitDocument: ->
    child.exitDocument() for child in @childs

  firstChild: ->

  lastChild: ->

  next: ->

  prev: ->
