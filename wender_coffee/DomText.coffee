

class ns.DomText extends ns.DomNode
  kind: 'text'

  # Params:
  #   values - array of ObservableValue
  #   render - function for rendering values to text
  constructor: (values, render) ->
    super()

    @text = ''
    @node = document.createTextNode(@text)
    @values = values
    @render = render

  setText: (text) ->
    @text = text
    @node.textContent = text

  # private

  enterDocument: ->
    # listen values change
    for value in @values
      value.addListener(@onValueChange)

    super()

  exitDocument: ->
    # unlisten values change
    for value in @values
      value.removeListener(@onValueChange)

    super()

  # events

  onValueChange: (oldValue, newValue) =>
    @setText(@render(@values))

