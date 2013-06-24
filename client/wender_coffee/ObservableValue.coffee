

class ns.ObservableValue extends ns.Observable

  constructor: ->
    super()
    @value = null

  setValue: (value) ->
    if @value isnt value
      oldValue = @value
      @value = value
      @notify(oldValue, value)

  notify: (oldValue, newValue) ->
    for hash, listener of @listeners
      listener(oldValue, newValue)


ns.createValue = (value) ->
  val = new ns.ObservableValue()
  val.setValue(value)
  return val
