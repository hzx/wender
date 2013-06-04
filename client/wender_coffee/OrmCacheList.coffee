

class ns.OrmCacheList extends ns.OrmList

  constructor: (type, name, parent) ->
    super([])
    @ormType = type
    @ormName = if !! name then name else null
    @ormParent = if !! parent then parent else null
    @hashGenerator = new ns.HashGenerator()

    # world collection
    @ormSrc = null

  setSrc: (src) ->
    # unlisten old collection
    if @ormSrc isnt null
      @unlistenSrcEvents()
    # listen events
    @ormSrc = src
    @listenSrcEvents()
    # copy orm params
    @ormParent = src.ormParent
    @ormName = src.ormName
    
  listenSrcEvents: ->
    @ormSrc.addListener(@onSrcChange)
    @ormSrc.addInsertListener(@onSrcInsert)
    @ormSrc.addDeleteListener(@onSrcDelete)

  unlistenSrcEvents: ->
    @ormSrc.removeListener(@onSrcChange)
    @ormSrc.removeInsertListener(@onSrcInsert)
    @ormSrc.removeDeleteListener(@onSrcDelete)

  # events
  
  onSrcChange: (oldvalue, newvalue) =>
    # change value without sync

  onSrcInsert: (obj, before) =>
    # append without sync
    if before is null
      @append(obj, false)
    # insert before without sync
    else
      @insertBefore(obj, before, false)

  onSrcDelete: (obj) =>
    # delete without sync
    @remove(obj.getHash(), false)

