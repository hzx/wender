

class ns.Validator

  constructor: ->

  # validate methods

  maxLength: (actual, value) ->
    actual.length is value

  lt: (actual, value) ->
    actual < value

  ltDatetime: (actual, value) ->

  lte: (actual, value) ->
    actual <= value

  ltDatetime: (actual, value) ->

  gt: (actual, value) ->
    actual > value

  gtDatetime: (actual, value) ->

  gte: (actual, value) ->
    actual >= value

  gteDatetime: (actual, value) ->

  regex: (actual, regex) ->
    regex.test(actual)
