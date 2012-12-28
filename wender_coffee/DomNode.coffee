
# TODO(dem) need ObservableNode
class ns.DomNode

  constructor: ->
    # parent node
    @parent = null
    # next siblings tag
    @next = null
    # previous siblings tag
    @prev = null
    # current node
    @node = null
    # tag childs
    @childs = []
    @firstChild = null
    @lastChild = null

  append: (child) ->
    @node.appendChild(child.node)
    @childs.append(child)
    child.parent = @node

  remove: ->
    @node.parentNode.removeChild(@node)
