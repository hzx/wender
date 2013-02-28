

class ns.DomRawElement extends ns.DomElement
  kind: 'raw_element'

  constructor: (html, attributes, childs, list, render) ->
    super('div', attributes, childs, list, render)
    @html = html

  enterDocument: ->
    super()
    @node.innerHTML = @html

  exitDocument: ->
    super()
