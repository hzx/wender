

class ns.OrmValue extends ns.ObservableValue
  ormKind: 'value'

  constructor: (type, name, parent, value) ->
    super()
    @ormType = type
    @ormName = if !!name then name else null
    @ormParent = if !!parent then parent else null
    @value = value

  setValue: (value, sync = true) ->
    isChanged = @value isnt value
    super(value)
    if isChanged
      if sync
        ns.orm.onSetValue(this)

  clone: ->
    return new ns.OrmValue(@ormType, @ormName, null, @value)
