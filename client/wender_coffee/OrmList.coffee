

# TODO(dem) implement sync
class ns.OrmList extends ns.ObservableList
  ormKind: 'list'

  constructor: (type, name, parent) ->
    super([])
    @ormType = type
    @ormName = if !! name then name else null
    @ormParent = if !! parent then parent else null
    @hashGenerator = new ns.HashGenerator()

  setTemporaryId: (obj) ->
    if obj.id.value is null or obj.id.value.length is 0
      obj.id.value = @hashGenerator.generate().toString()

  updateId: (oldid, newid) ->
    if not (oldid of @nodes)
      return
    # get obj
    node = @nodes[oldid]
    # delete old from nodes
    delete @nodes[oldid]
    # add new to nodes
    @nodes[newid] = node
    # update id
    node.obj.id.setValue(newid, false)

  insert: (obj, sync = true) ->
    # @setTemporaryId(obj)
    # obj.ormParent = this
    # super(obj)
    # ns.orm.onInsert(obj)
    @append(obj, sync)

  append: (obj, sync = true) ->
    @setTemporaryId(obj)
    obj.ormParent = this
    super(obj)
    if sync
      ns.orm.onAppend(this, obj)

  insertAfter: (obj, after, sync = true) ->
    @setTemporaryId(obj)
    obj.ormParent = this
    super(obj, after)
    if sync
      ns.orm.onInsertAfter(this, obj, after)

  insertBefore: (obj, before, sync = true) ->
    @setTemporaryId(obj)
    obj.ormParent = this
    super(obj, before)
    if sync
      ns.orm.onInsertBefore(this, obj, before)

  remove: (hash, sync = true) ->
    orphan = super(hash)
    if orphan isnt null
      orphan.ormParent = null
      if sync
        ns.orm.onRemove(this, orphan)
    return orphan

  removeSilent: (hash) ->
    @remove(hash, false)

  empty: (sync = true) ->
    for hash, node of @nodes
      this.remove(hash, sync)

  emptySilent: ->
    for hash, node of @nodes
      this.removeSilent(hash)

  clone: ->
    list = new ns.OrmList(@ormType, @ormName, null)
    # copy all values from current list
    cursor = @first
    while cursor isnt null
      list.append(cursor.obj.clone(), false)
      cursor = cursor.next
    return list

