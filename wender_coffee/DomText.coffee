

class ns.DomText extends ns.DomNode
  kind: 'text'

  # Params:
  #   values - array of ObservableValue
  #   render - function for rendering values to text
  constructor: (text, values, render) ->
    super()

    @text = text
    @node = document.createTextNode(@text)
    @values = values
    @render = render

  setText: (text) ->
    @text = text
    @node.textContent = text

  renderText: ->
    @setText(@render(@values))

  # private

  enterDocument: ->
    # listen values change
    if @values isnt null
      for value in @values
        value.addListener(@onValueChange)

      # autorender values
      if @values.length > 0
        @renderText()

    super()

  exitDocument: ->
    # unlisten values change
    if @values isnt null
      for value in @values
        value.removeListener(@onValueChange)

    super()

  # events

  onValueChange: (oldValue, newValue) =>
    @renderText()

