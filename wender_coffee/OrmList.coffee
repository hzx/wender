

class ns.OrmList extends ns.ObservableList

  constructor: (name, parent) ->
    super()
    @ormName = name
    @ormParent = parent
    @hashGenerator = new ns.HashGenerator()

  setTemporaryId: (obj) ->
    if obj.id.value is null
      obj.id.value = @hashGenerator.generate().toString()

  insert: (obj) ->
    setTemporaryId(obj)
    obj.ormParent = this
    super(obj)
    getOrmNames(obj)
    ns.orm.insert(obj)

  append: (obj) ->
    setTemporaryId(obj)
    obj.ormParent = this
    super(obj)
    ns.orm.append(obj)

  insertAfter: (obj, after) ->
    setTemporaryId(obj)
    obj.ormParent = this
    super(obj, after)
    ns.orm.insertAfter(obj, after)

  insertBefore: (obj, before) ->
    setTemporaryId(obj)
    obj.ormParent = this
    super(obj, before)
    ns.orm.insertBefore(obj, before)

  remove: (hash) ->
    orphan = super(hash)
    if orphan isnt null
      ns.orm.remove(orphan)
      orphan.ormParent = null
      orphan
    else 
      null
