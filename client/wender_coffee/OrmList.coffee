

class ns.OrmList extends ns.ObservableList
  ormKind: 'list'

  constructor: (type, name, parent) ->
    super([])
    @ormType = type
    @ormName = if name then name else null
    @ormParent = if parent then parent else null
    @hashGenerator = new ns.HashGenerator()

  setTemporaryId: (obj) ->
    if obj.id.value is null or obj.id.value.length is 0
      obj.id.value = @hashGenerator.generate().toString()

  insert: (obj) ->
    @setTemporaryId(obj)
    obj.ormParent = this
    super(obj)
    getOrmNames(obj)
    ns.orm.onInsert(obj)

  append: (obj) ->
    @setTemporaryId(obj)
    obj.ormParent = this
    super(obj)
    ns.orm.onAppend(obj)

  insertAfter: (obj, after) ->
    @setTemporaryId(obj)
    obj.ormParent = this
    super(obj, after)
    ns.orm.onInsertAfter(obj, after)

  insertBefore: (obj, before) ->
    @setTemporaryId(obj)
    obj.ormParent = this
    super(obj, before)
    ns.orm.onInsertBefore(obj, before)

  remove: (hash) ->
    orphan = super(hash)
    if orphan isnt null
      ns.orm.onRemove(orphan)
      orphan.ormParent = null
      orphan
    else
      null

  empty: ->
    for hash, node of @nodes
      this.remove(hash)

  clone: ->
    list = new ns.OrmList(@type, @name, null)
    # copy all values from current list
    cursor = @first
    while cursor isnt null
      child = cursor.obj
      clone = child.clone()
      cursor = cursor.next
      list.append(clone)

