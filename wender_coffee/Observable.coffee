

class ns.Observable

  constructor: ->
    @listeners = {}
    @hshCounter = 0

  generateHsh: ->
    @hshCounter = @hshCounter + 1
    @hshCounter

  addListener: (listener) ->
    # get listener hash
    hsh = null
    if 'hsh' of listener
      hsh = listener.hsh
    else
      # mark listener by hsh
      hsh = @generateHsh()
      listener.hsh = hsh
    
    if not (hsh of @listeners)
      @listeners[hsh] = listener

  removeListener: (listener) ->
    # get listener hash
    if 'hsh' of listener
      hsh = listener.hsh
      delete @listeners[hsh]
