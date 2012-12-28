

class ns.DomText extends ns.DomNode
  @kind = 'text'

  constructor: (text) ->
    @node = document.createTextNode(text)

  setText: (text) ->
