

class ns.OrmValue extends ns.ObservableValue

  constructor: (name) ->
    super()
    @ormName = name

  setValue: (value) ->
    @super(value)
    ns.orm.setValue(@ormName, value)
