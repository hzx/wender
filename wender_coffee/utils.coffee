

class ns.HashGenerator
  constructor: ->
    @hashCounter = 0

  generate: ->
    @hashCounter = @hashCounter + 1
    @hashCounter
