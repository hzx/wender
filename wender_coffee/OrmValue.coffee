

class ns.OrmValue extends ns.ObservableValue
  ormKind: 'value'

  constructor: (type, name, parent) ->
    super()
    @ormType = type
    @ormName = name
    @ormParent = parent

  setValue: (value) ->
    @super(value)
    ns.orm.setValue(this)
