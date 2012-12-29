

class ns.DomElement extends ns.DomNode
  @kind = 'element'

  constructor: (tagName, attributes, childs, list, render) ->
    @tagName = tagName
    @attributes = attributes
    @node = document.createElement(tagName)
    # child collection
    @list = list
    # function for render follection item
    @render = render
    # object rendered by render function
    @renderedObject = null
    # map object id from list to rendered node by render function
    @nodeItemMap = {}

  setAttribute: (name, value) ->

  enterDocument: ->
    # listen list events
    # call super method
    super()

  exitDocument: ->
    # unlisten list events
    # call super method
    super()

  onListAppend: (obj) ->
