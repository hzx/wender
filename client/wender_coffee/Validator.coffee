

class ns.Validator

  constructor: ->
    @reCache = {}

  # validate methods

  maxLength: (actual, value) ->
    return actual.length <= value

  lt: (actual, value) ->
    return actual < value

  ltDatetime: (actual, value) ->

  lte: (actual, value) ->
    return actual <= value

  ltDatetime: (actual, value) ->

  gt: (actual, value) ->
    return actual > value

  gtDatetime: (actual, value) ->

  gte: (actual, value) ->
    return actual >= value

  gteDatetime: (actual, value) ->

  regex: (actual, regex) ->
    rec = @reCache[regex] or @reCache[regex] = new RegExp(regex)
    return rec.test(actual)
