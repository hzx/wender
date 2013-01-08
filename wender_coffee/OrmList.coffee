

class ns.OrmList extends ns.ObservableList

  constructor: (name) ->
    super()
    @ormName = name
    @hashGenerator = new ns.HashGenerator()

  setTemporaryId: (obj) ->
    if obj.id.value is null
      obj.id.value = @hashGenerator.generate().toString()

  insert: (obj) ->
    super(obj)
    ns.orm.insert(@ormName, obj)

  append: (obj) ->
    setTemporaryId(obj)
    super(obj)
    ns.orm.append(@ormName, obj)

  insertAfter: (obj, after) ->
    setTemporaryId(obj)
    super(obj, after)
    ns.orm.insertAfter(@ormName, obj, after)

  insertBefore: (obj, before) ->
    setTemporaryId(obj)
    super(obj, before)
    ns.orm.insertBefore(@ormName, obj, before)

  remove: (hash) ->
    super(hash)
    ns.orm.remove(@ormName, hash)
