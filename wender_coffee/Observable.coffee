

class ns.Observable

  constructor: ->
    @listeners = {}
    @hashGenerator = new ns.HashGenerator()

  addListener: (listener) ->
    # get listener hash
    hash = null
    if 'hash' of listener
      hash = listener.hash
    else
      # mark listener by hsh
      hash = @hashGenerator.generate()
      listener.hash = hash
    
    if not (hash of @listeners)
      @listeners[hash] = listener

  removeListener: (listener) ->
    # get listener hash
    if 'hash' of listener
      hash = listener.hash
      delete @listeners[hash]
