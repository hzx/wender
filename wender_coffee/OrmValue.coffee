

class ns.OrmValue extends ns.ObservableValue
  ormKind: 'value'

  constructor: (type, name, parent, value) ->
    super()
    @ormType = type
    @ormName = name
    @ormParent = parent
    @value = value

  setValue: (value) ->
    @super(value)
    ns.orm.setValue(this)
