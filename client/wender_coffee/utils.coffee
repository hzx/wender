

class ns.HashGenerator
  constructor: ->
    @hashCounter = 0

  generate: ->
    @hashCounter = @hashCounter + 1
    @hashCounter


encodeDict = (dict) ->
  isFirst = true
  result = ""
  for key, value of dict
    if isFirst then isFirst = false else result = result + "&"
    result = result + key + "=" + encodeURIComponent(value)
  result

