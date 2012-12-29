

class ns.DomText extends ns.DomNode
  @kind = 'text'

  constructor: (values, renderText) ->
    @node = document.createTextNode(text)
    @values = values
    @renderText = renderText

  enterDocument: ->

  exitDocument: ->

  onValueChanged: ->
    # or @node.nodeValue = 
    @node.textContent = @renderText(@values)
