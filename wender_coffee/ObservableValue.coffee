

class ns.ObservableValue extends ns.Observable

  constructor: ->
    @value = null

  setValue: (value) ->
    if value isnt @value
      oldValue = @value
      @value = value
      @notify(oldValue, value)

  notify: (oldValue, newValue) ->
    for hsh, listener of @listeners
      listener(oldValue, newValue)