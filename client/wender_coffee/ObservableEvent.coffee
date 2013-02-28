

class ns.ObservableEvent extends ns.Observable

  constructor: ->
    super()

  notify: (event) ->
    for hash, listener of @listeners
      listener(event)
