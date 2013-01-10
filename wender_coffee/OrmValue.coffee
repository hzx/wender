

class ns.OrmValue extends ns.ObservableValue

  constructor: (name, parent) ->
    super()
    @ormName = name
    @ormParent = parent

  setValue: (value) ->
    @super(value)
    ns.orm.setValue(this)
