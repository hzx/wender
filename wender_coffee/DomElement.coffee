

class ns.DomElement extends ns.DomNode
  @kind = 'element'

  constructor: (tagName, attributes, childs) ->
    @tagName = tagName
    @attributes = attributes
    @node = document.createElement(tagName)
