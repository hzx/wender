

class ns.OrmValue extends ns.ObservableValue
  ormKind: 'value'

  constructor: (type, name, parent, value) ->
    super()
    @ormType = type
    @ormName = if !! name then name else null
    @ormParent = if !! parent then parent else null
    @value = value

  setValue: (value) ->
    super(value)
    ns.orm.onSetValue(this)

  clone: ->
    return new ns.OrmValue(@type, @name, null, @value)
