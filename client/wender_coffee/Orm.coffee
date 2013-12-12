
###
Download order:
- at once all no lazy
- lazy list download only count

Changes:
- value change, find if parent list then check ref to this or from this

ORM params
common:
- access for users, consist of 2 symbols for every user, user order: owner, user
  "r" - read, "w" - write, "-" - forbidden
  access:'rwrw'
  access:'r-rw'
  access:'r-r-'
for value:
- default:value
- index:asc|desc
- maxLength:value
- lt:value - <
- lte:value - <=
- gt:value - >
- gte:value - >=
- regex:litstring
- thumbSizes:['160x120', 320x240']
- thumbCrop:true
- imageSizes:['1200x400', '2400x800']
- imageCrop:true
for list:
- lazy:true|false, by default lazy:true, list download at once or by query request
- ref:'collName' contains only id's, may be ordered,
- link:'collName' contains only id's, work like ordered copy
  affect only object changes
###


# get array of orm names from parent to child
# obj is OrmValue, OrmList, struct class from base OrmStruct or OrmHashStruct
getOrmNames = (obj) ->
  names = []
  cursor = obj
  # while obj.ormName isnt null
  while cursor isnt null
    # names.push(obj.ormName)
    if cursor.ormName isnt null
      names.push(cursor.ormName)
    cursor = cursor.ormParent
  names.reverse()
  return names


# TODO(dem) implement it
getOrmSequence = (obj, child = null) ->
  ###
  Create node sequences of objects from parent to obj
  ###
  # for world return child sequence
  if obj.ormName is 'world'
    return child

  if obj.ormKind is 'value'
    # value must have parent, grandpa and parent is struct
    if (obj.ormParent is null) or (obj.ormParent.ormParent is null) or (obj.ormParent.ormKind isnt 'struct')
      return null

    grandpa = obj.ormParent.ormParent

    node = {
      'kind': 'value',
      'name': obj.ormName,
      'value': obj.value,
      'parentid': obj.ormParent.id.value
    }

    # for grandpa struct
    if grandpa.ormKind is 'struct'
      node['parentname'] = obj.ormParent.ormName

    # for grandpa list - do nothing
    # if grandpa.ormKind is 'list'
    #   throw new Error('for grandpa list parent name must be null:' + obj.ormParent.ormName)
    
    return getOrmSequence(grandpa, node)

  if obj.ormKind is 'struct'
    node = {
      'kind': 'struct',
      'name': obj.ormName,
      'child': child
    }
    return getOrmSequence(obj.ormParent, node)

  if obj.ormKind is 'list'
    node = {
      'kind': 'list',
      'name': obj.ormName,
      'child': child
    }
    return getOrmSequence(obj.ormParent, node)

  return null


# base class for struct
class ns.OrmStruct
  ormKind: 'struct'

  constructor: (type, name, parent) ->
    @ormType = type
    @ormName = if !! name then name else null
    @ormParent = if !! parent then parent else null


# Base class for struct with id
class ns.OrmHashStruct extends ns.OrmStruct
  constructor: (type, name, parent) ->
    super(type, name, parent)

  setHash: (hash) ->
    # set value directly
    @id.value = hash

  getHash: ->
    @id.value

  addHashListener: (listener) ->
    @id.addListener(listener)

  removeHashListener: (listener) ->
    @id.removeListener(listener)


class OrmStructMeta
  constructor: (name, fields) ->
    @kind = name
    @fields = @parseFields(fields)

  parseFields: (fields) ->
    return fields


# class ns.OrmField
# 
#   constructor: (type, name, params) ->
#     @type = type
#     @name = name
#     @params = params
# 
# class ns.OrmStruct
# 
#   constructor: (name, fields) ->
#     @name = name
#     @fields = fields

# TODO(dem) Change, validate values of types OrmValue, OrmList
# Send/receive data by Net
class ns.Orm
  constructor: ->
    # map struct name to params (fields, create structClass method)
    @structs = {}

    @validator = new ns.Validator()

    @model = null
    @world = null

    @reflink = []

    @paramToValidate = {
      'maxLength': @validator.maxLength,
      'lt': @validator.lt,
      'lte': @validator.lte,
      'gt': @validator.gt,
      'gte': @validator.gte,
      'regex': @validator.regex
    }

    # orm operations url
    @urlOp = '/op'

    # hash for operations
    @opHashGenerator = new ns.HashGenerator()
    # save op hash to dest coll
    @selectOneOps = {}
    @selectFromOps = {}
    @insertOps = {}

  init: ->
    # parse all structs

  setStructs: (structs) ->
    @structs = structs
    # store coll dotnames to array of refs dotnames
    @collToRefs = {}
    # store coll dotnames to array of links dotnames
    @collToLinks = {}

  load: (url, modelNs, world, callback) ->
    @model = modelNs
    @world = world
    @loadCallback = callback
    ns.net.get(url, @onLoadSuccess, @onLoadFail)

  addToCache: (hash, val) ->
    @insertOps[hash] = val
  getFromCache: (hash) ->
    return @insertOps[hash]
  deleteFromCache: (hash) ->
    delete @insertOps[hash]

  fillWorld: (data) ->
    meta = @structs['World']
    bufarr = {}
    buf = {}
    # sort data, arrays fill first
    for name, value of data
      params = meta[name]
      if params.isArray# and not (!!('ref' of params) or !!('link' of params))
        bufarr[name] = value
      else
        buf[name] = value

    # fill world
    @fillStruct(@world, bufarr, 'World')
    @fillStruct(@world, buf, 'World')

    @fillRefLinkArrayNow()

  fillArray: (dest, data, typename) ->
    # for every data item create field object and fill
    for item in data
      field = new @model[typename]
      @fillStruct(field, item, typename)
      dest.append(field, false)

  fillRefLinkArrayNow: ->
    for item in @reflink
      @fillRefLinkArray(item)

  fillRefLinkArrayLater: (dest, data, typename, rlarr) ->
    @reflink.push([dest, data, typename, rlarr])

  fillRefLinkArray: (item) ->
    dest = item[0]
    data = item[1]
    typename = item[2]
    rlarr = item[3]
    for item in data
      # clone data from rlarr
      rlobj = rlarr.get(item)
      if (!!rlobj) is false then continue
      field = rlobj.clone()
      dest.append(field, false)

  fillValue: (dest, data, valuetype) ->
    # debug
    # console.log('dest:')
    # console.log(dest)

    if (!! data) is false
      return null
    if valuetype is 'int'
      # console.log('valuetype int')
      data = parseInt(data)
    if valuetype is 'float'
      # console.log('valuetype float')
      data = parseFloat(data)
    dest.setValue(data, false)

  fillStruct: (dest, data, typename) ->
    if (!! data) is false
      return null

    meta = @structs[typename]
    # fill every document
    for name, value of data
      # get doc structure by name
      params = meta[name]
      if !!params is false
        continue
      # fill field depend on type
      if params.isArray
        # skip loading lazy
        if @isArrayLazy(params)
          continue
        if 'ref' of params
          refarr = @world[params.ref]
          @fillRefLinkArrayLater(dest[name], value, params.type, refarr)
          continue
        if 'link' of params
          linkarr = @world[params.link]
          @fillRefLinkArrayLater(dest[name], value, params.type, linkarr)
          continue
        @fillArray(dest[name], value, params.type)
      else
        if params.isValueType
          # debug
          # console.log('before fillValue name=' + name)
          # console.log(dest)
          @fillValue(dest[name], value, params.type)
        else
          @fillStruct(dest[name], value, params.type)

  isArrayLazy: (params) ->
    # detect lazy by source array
    if 'ref' of params
      # get source array params
      world = @structs['World']
      params = world[params.ref]
    if 'link' of params
      world = @structs['World']
      params = world[params.link]
    # by default lazy is true
    return if 'lazy' of params then params['lazy'] else true

  getFieldParams: (field) ->
    # take parent ormType
    ormtype = field.ormParent.ormType
    # search struct with ormtype
    st = @structs[ormtype]
    if !!st is false then return null

    params = st[field.ormName]
    if !!params is false then return null

    return params

  # Validate value
  
  validate: (obj) ->
    # obj maybe struct, list or value
    
    # need struct or struct, field name to get validate params
    
    # validate obj
    parent = obj.ormParent

  # work with structs

  # work with server orm

  uploadImages: (field, files, success, fail) ->
    ###
    # Params:
    # field - struct.field string, need to detect image sizes
    # files - files to send
    # success - hash, contain filenames
    ###
    hash = @opHashGenerator.generate().toString()
    data = {
      'op': 'upload_images',
      'field': field,
      'hash': hash
    }

    ns.net.uploadFiles(@urlOp, 'imgs', files, data, success, fail)
    return hash

  # field must be dot_names
  updateImage: (field, file, success, fail) ->
    data = {
      'op': 'update_image',
    }
    ops = [
      {'update_image': field}
    ]
    strOps = JSON.stringify(ops)
    ns.net.uploadFiles(@urlOp, 'imgs', [file], strOps, success, fail)

  insertImages: (field, files, success, fail) ->
    ops = [
      {'insert_images': field}
    ]
    strOps = JSON.stringify(ops)
    ns.net.uploadFiles(@urlOp, 'imgs', files, strOps, success, fail)

  structToJson: (obj) ->
    # get obj struct
    st = @structs[obj.ormType]
    # json buffer
    buf = {}
    # for every field serialize it
    for field, params of st
      objfield = obj[field]
      if params.isArray
        if 'ref' of params
          buf[field] = @refToJson(objfield, params)
        else
          if 'link' of params
            buf[field] = @linkToJson(objfield, params)
          else
            buf[field] = @arrayToJson(objfield, params)
      else
        if params.isValueType
          # fill value
          buf[field] = @valueToJson(objfield, params)
        else
          # fill struct
          buf[field] = @structToJson(objfield)
    return buf

  arrayToJson: (arr, params) ->
    buf = []
    cursor = arr.first
    while cursor isnt null
      buf.push(@structToJson(cursor.obj))
      cursor = cursor.next
    return buf

  refToJson: (arr, params) ->
    buf = []
    for item in arr
      buf.push(item.getHash())
    return buf

  linkToJson: (arr, params) ->
    buf = []
    for item in arr
      buf.push(item.getHash())
    return buf

  valueToJson: (val, params) ->
    return val.value

  # CRUD OPERATIONS

  insert: (coll, val) ->
    coll.insert(val)

  insertAfter: (coll, val, objid) ->
    # obj = @selectOne(coll, whereFn)
    # if obj isnt null
    coll.insertAfter(val, objid)

  insertBefore: (coll, val, objid) ->
    # obj = @selectOne(coll, objid)
    # if obj isnt null
    coll.insertBefore(val, objid.value)

  selectCount: (coll) ->
    return coll.count

  selectOne: (coll, whereFn, slug, callback) ->
    if @isCollectionLazy(coll)
      # load collection from server
      names = getOrmNames(coll)
      hash = @opHashGenerator.generate().toString()
      data = {
        'op': 'select_one',
        'hash': hash,
        'coll': names.join('.'),
        'slug': slug
      }
      # add parent id if exists
      if (coll.ormParent isnt null) and (coll.ormParent.ormName isnt 'world')
        data['parent'] = coll.ormParent.id.value
      # save dest to operations map
      @selectOneOps[hash] = {'coll': coll, 'slug': slug, 'callback': callback}
      ns.net.post(@urlOp, data, @onNetSelectOne, @onNetSelectOneFail)
    else
      if !!slug
        return coll.getBy('slug', slug)
      return coll.get(whereFn.id.value)

  find: (url, dest, coll, data, success, error) ->
    me = this
    data['coll'] = getOrmNames(coll).slice(1).join('.')
    dest.emptySilent()
    ns.net.post(
      url,
      data,
      (response) ->
        res = JSON.parse(response)
        dest.setSrc(coll)
        me.fillArray(dest, res['coll'], coll.ormType)
        success(res['prev'], res['next'])
      ,
      (status) ->
        error(status)
      )

  selectFrom: (dest, coll, whereFn, orderField, limit, success = null, error = null) ->
    # if coll is lazy, select from server
    if @isCollectionLazy(coll)
      # load collection from server
      names = getOrmNames(coll)
      if (names.length > 0) and (names[0] isnt 'world')
        return null
      hash = @opHashGenerator.generate().toString()
      data = {
        'op': 'select_from',
        'hash': hash,
        'coll': names.join('.'),
        'where': JSON.stringify(whereFn)
      }
      # if (orderField isnt null)
      #   data['order'] = JSON.stringify(orderField)
      # add parent id if exists
      if (coll.ormParent isnt null) and (coll.ormParent.ormName isnt 'world')
        data['parent'] = coll.ormParent.id.value
      if !!limit
        data['limit'] = limit
      # save dest to operations map
      # @selectFromOps[hash] = {
      #   'dest': dest,
      #   'coll': coll,
      #   'ormType': coll.ormType,
      #   'success': success
      # }
      dest.emptySilent()
      # @onNetSelectFrom, 
      # @onNetSelectFromFail
      me = this
      ns.net.post(@urlOp, data,
        (response) ->
          res = JSON.parse(response)
          # set dest coll as coll cache, copy orm properties
          dest.ormType = coll.ormType
          dest.ormName = coll.ormName
          dest.ormParent = coll.ormParent

          me.fillArray(dest, res.coll, coll.ormType)

          if !!success
            success()
        ,
        (status) ->
          if !!error
            error(status)
        )
    else
      # load collection from cache
      dest.emptySilent()
      # set src collection
      dest.setSrc(coll)
      # add nodes
      cursor = coll.first
      while cursor isnt null
        dest.append(cursor.obj.clone(), false)
        cursor = cursor.next
      if !!success
        success()

  selectConcat: (dest, colls) ->
    dest.emptySilent()
    for coll in colls
      cursor = coll.first
      while cursor isnt null
        dest.append(cursor.obj.clone(), false)
        cursor = cursor.next

  selectSum: (coll, byField) ->
    # console.log 'orm.selectSum'
    # console.log coll
    sum = 0

  update: (coll, vals, id) ->
    # debug
    # console.log 'orm.update'
    # console.log coll
    # console.log vals
    # console.log whereFn
    
    names = getOrmNames(coll)
    if (names.length > 0) and (names[0] isnt 'world')
      return null
    data = {
      'op': 'update',
      'coll': names.join('.'),
      'values': JSON.stringify(@structToJson(vals)),
      'id': id.value
    }
    ns.net.post(@urlOp, data, @onNetUpdate, @onNetUpdateFail)

  checkPaging: (coll, wprev, wnext, success) ->
    hash = @opHashGenerator.generate().toString()
    names = getOrmNames(coll)
    data = {
      'op': 'paging',
      'hash': hash,
      'coll': names.join('.'),
      'wprev': JSON.stringify(wprev),
      'wnext': JSON.stringify(wnext)
    }

    @insertOps[hash] = {'success': success}

    ns.net.post(@urlOp, data, @netCheckPaging, @netCheckPagingFail)

  netCheckPaging: (response) =>
    res = JSON.parse(response)
    params = @insertOps[res.hash]
    delete @insertOps[res.hash]

    params['success'](res.prev, res.next)

  netCheckPagingFail: (status) =>
    console.log('netCheckPagingFail:')
    console.log(status)

  updateRaw: (coll, vals, wh) ->
    names = getOrmNames(coll)
    if (names.length > 0) and (names[0] isnt 'world')
      return null
    data = {
      'op': 'update_raw',
      'coll': names.join('.'),
      'values': JSON.stringify(vals),
      'where': JSON.stringify(wh)
    }
    ns.net.post(@urlOp, data, @onNetUpdateRaw, @onNetUpdateRawFail)

  deleteWhere: (coll, where) ->
    names = getOrmNames(coll)
    if (names.length is 0) or ((names.length > 0) and (names[0] isnt 'world'))
      return null

    data = {
      'op': 'delete_where',
      'coll': names.join('.'),
      'where': JSON.stringify(where)
    }

    netDeleteWhere = (response) ->
      res = JSON.parse(response)
      ids = res['ids']
      for id in ids
        coll.remove(id, false)

    netDeleteWhereFail = (status) ->
      console.log('netDeleteWhereFail')
      console.log(status)

    ns.net.post(@urlOp, data, netDeleteWhere, netDeleteWhereFail)

  # this duplicate onRemove
  deleteFrom: (coll, id) ->
    coll.remove(id.value)
    return false

    names = getOrmNames(coll)
    if (names.length > 0) and (names[0] isnt 'world')
      return null

    # debug
    # console.log('Orm.deleteFrom')
    # console.log coll
    # console.log id

    # delete from local collection
    coll.remove

    data = {
      'op': 'delete',
      'coll': names.join('.'),
      'id': id.value
    }
    ns.net.post(@urlOp, data, @onNetRemove, @onNetRemoveFail)

  getImageSize: (filename) ->
    if filename.value.length is 0
      return null

    params = @getFieldParams(filename)
    if params is null then return null

    imageSizes = params.imageSizes
    if !!imageSizes is false
      return null

    return imageSizes[0]

  getImageUrl: (filename) ->
    size = this.getImageSize(filename)
    if size is null
      return ''
    # if filename.value.length is 0
    #   return ''

    # params = @getFieldParams(filename)
    # if params is null then return ''

    # imageSizes = params.imageSizes
    # if !!imageSizes is false
    #   return ''

    # return '/static/img/' + imageSizes[0] + '_' + filename.value
    return '/static/img/' + size + '_' + filename.value

  getThumbUrl: (filename) ->
    if filename.value.length is 0
      return ''

    params = @getFieldParams(filename)
    if params is null then return ''

    thumbSizes = params.thumbSizes
    if !!thumbSizes is false
      return ''

    return '/static/img/' + thumbSizes[0] + '_' + filename.value

  findImageStruct: (image) ->

  isWorldNames: (names) ->
    return (names.length > 0) and (names[0] is 'world')

  bunchAppend: (coll, objs) ->
    names = getOrmNames(coll)
    if (names.length > 0) and (names[0] isnt 'world')
      return null
    data = {
      'op': 'bunch_append',
      'coll': names.join('.'),
      # 'objs': JSON.stringify(
    }
    ns.net.post(@urlOp, data, @onNetBunchAppend, @onNetBunchAppendFail)
    
  bunchInsertBefore: (coll, objs, before) ->
    names = getOrmNames(coll)
    if (names.length > 0) and (names[0] isnt 'world')
      return null
    data = {
      'op': 'bunch_insert_before',
      'coll': names.join('.'),
    }
    ns.net.post(@urlOp, data,
      @onNetBunchInsertBefore, @onNetBunchInsertBeforeFail)

  # events

  onLoadSuccess: (response) =>
    # parse all response
    parsed = JSON.parse(response)
    # set net xsrf
    ns.net.setXsrf(parsed.xsrf)
    # fill world
    @fillWorld(parsed.data)
    # call callback
    @loadCallback()

  onLoadFail: (status) =>
    console.log('onLoadFail')
    console.log(status)

  # event OrmList, OrmValue operations
  
  onSetValue: (obj) ->
    names = getOrmNames(obj)
    if not @isWorldNames(names)
      return
    ormobj = getOrmSequence(obj)

    # validate
    
    # change referenced values

    # seq = JSON.stringify(ormobj)
    # console.log('onSetValue:')
    # console.log(seq)

    data = {
      'op': 'value',
      'seq': JSON.stringify(ormobj)
    }
    
    # send changes by net
    ns.net.post(@urlOp, data, @onNetSetValue, @onNetSetValueFail)

  
  onInsert: (coll, obj, success, error) =>
    # validate
    # change referenced values
    # send changes by net
    names = getOrmNames(coll)
    if (names.length > 0) and (names[0] isnt 'world')
      return null
    hash = @opHashGenerator.generate().toString()
    data = {
      'op': 'insert',
      'hash': hash,
      'coll': names.join('.'),
      'obj': JSON.stringify(@structToJson(obj))
    }
    # add parent id if exists
    if (coll.ormParent isnt null) and (coll.ormParent.ormName isnt 'world')
      data['parent'] = coll.ormParent.id.value
    # save operation to buffer
    @insertOps[hash] = { 'coll': coll }
    ns.net.post(@urlOp, data, @onNetInsert, @onNetInsertFail)

  onAppend: (coll, obj) =>
    names = getOrmNames(coll)
    if (names.length > 0) and (names[0] isnt 'world')
      return null
    hash = @opHashGenerator.generate().toString()
    data = {
      'op': 'append',
      'hash': hash,
      'coll': names.join('.'),
      'obj': JSON.stringify(@structToJson(obj))
    }
    # add parent id if exists
    if (coll.ormParent isnt null) and (coll.ormParent.ormName isnt 'world')
      data['parent'] = coll.ormParent.id.value
    # save operation to buffer
    @insertOps[hash] = {'coll': coll}
    ns.net.post(@urlOp, data, @onNetAppend, @onNetAppendFail)

  onInsertAfter: (coll, obj, after) =>
    # validate
    # change referenced values
    # send changes by net
    names = getOrmNames(coll)
    if (names.length > 0) and (names[0] isnt 'world')
      return null
    hash = @opHashGenerator.generate().toString()
    data = {
      'op': 'insert_after',
      'hash': hash,
      'coll': names.join('.'),
      'obj': JSON.stringify(@structToJson(obj)),
      'after': after.value
    }
    # add parent id if exists
    if (coll.ormParent isnt null) and (coll.ormParent.ormName isnt 'world')
      data['parent'] = coll.ormParent.id.value
    @insertOps[hash] = {'coll': coll}
    ns.net.post(@urlOp, data, @onNetInsertAfter, @onNetInsertAfterFail)

  onInsertBefore: (coll, obj, before) =>
    # validate
    # change referenced values
    # send changes by net

    # debug
    # console.log('before:')
    # console.log(before)
    
    names = getOrmNames(obj)
    if (names.length > 0) and (names[0] isnt 'world')
      return null
    hash = @opHashGenerator.generate().toString()
    data = {
      'op': 'insert_before',
      'hash': hash,
      'coll': names.join('.'),
      'obj': JSON.stringify(@structToJson(obj)),
      'before': before
    }
    # add parent id if exists
    if (coll.ormParent isnt null) and (coll.ormParent.ormName isnt 'world')
      data['parent'] = coll.ormParent.id.value
    @insertOps[hash] = {'coll': coll}
    ns.net.post(@urlOp, data, @onNetInsertBefore, @onNetInsertBeforeFail)

  onRemove: (coll, obj) =>
    names = getOrmNames(coll)
    if (names.length > 0) and (names[0] isnt 'world')
      return null
    data = {
      'op': 'delete',
      'coll': names.join('.'),
      'id': obj.id.value
    }

    # add parent id if exists
    if (coll.ormParent isnt null) and (coll.ormParent.ormName isnt 'world')
      data['parent'] = coll.ormParent.id.value

    # console.log('onRemove')
    # console.log(data)

    ns.net.post(@urlOp, data, @onNetRemove, @onNetRemoveFail)

    # names = getOrmNames(obj)
    # if not @isWorldNames(names)
    #   return
    # ormobj = getOrmSequence(obj.id)

    # data = {
    #   'op': 'delete',
    #   'seq': JSON.stringify(ormobj)
    # }
    
    # ns.net.post(@urlOp, data, @onNetRemove, @onNetRemoveFail)

  onNetSetValue: (response) =>
    abc = ''

  onNetSetValueFail: (status) =>
    console.log 'onNetSetValueFail, status:'
    console.log status

  onNetInsert: (response) =>
    # update old id if exists
    parsed = JSON.parse(response)
    if not (parsed.hash of @insertOps)
      return

    params = @insertOps[parsed.hash]
    delete @insertOps[parsed.hash]

    params.coll.updateId(parsed.oldid, parsed.newid)

  onNetInsertFail: (status) =>
    console.log('onNetInsertFail')
    console.log(status)

  onNetAppend: (response) =>
    # update old id if exists
    parsed = JSON.parse(response)
    if not (parsed.hash of @insertOps)
      return

    params = @insertOps[parsed.hash]
    delete @insertOps[parsed.hash]

    params.coll.updateId(parsed.oldid, parsed.newid)


  onNetAppendFail: (status) =>
    console.log('onNetAppendFail')
    console.log(status)

  onNetInsertAfter: (response) =>
    # update old id if exists
    console.log('onNetInsertAfter')
    console.log(response)

  onNetInsertAfterFail: (status) =>
    console.log('onNetInsertAfterFail')
    console.log(status)

  onNetInsertBefore: (response) =>
    # update old id if exists
    parsed = JSON.parse(response)
    if not (parsed.hash of @insertOps)
      return

    params = @insertOps[parsed.hash]
    delete @insertOps[parsed.hash]

    params.coll.updateId(parsed.oldid, parsed.newid)

  onNetInsertBeforeFail: (status) =>
    console.log('onNetInsertBeforeFail')
    console.log(status)

  onNetUpdate: (response) =>
    console.log('onNetUpdate')
    console.log(response)

  onNetUpdateFail: (status) =>
    console.log('onNetUpdateFail')
    console.log(status)

  onNetUpdateRaw: (response) =>
    # console.log('onNetUpdateRaw')
    # console.log(response)
  onNetUpdateRawFail: (status) =>
    console.log('onNetUpdateRawFail')
    console.log(status)

  onNetRemove: (response) =>
    # console.log('onNetRemove')
    # console.log(response)
    dummy = ''

  onNetRemoveFail: (status) =>
    console.log('onNetRemoveFail')
    console.log(status)

  onNetSelectOne: (response) =>
    parsed = JSON.parse(response)
    if not (parsed.hash of @selectOneOps)
      return

    params = @selectOneOps[parsed.hash]
    delete @selectOneOps[parsed.hash]


    instance = new @model[params.coll.ormType]
    @fillStruct(instance, parsed.obj, params.coll.ormType)
    instance.ormParent = params.coll

    params.callback(instance)

  onNetSelectOneFail: (status) =>
    abc = ''

  # onNetSelectFrom: (response) =>
  #   res = JSON.parse(response)
  #   # get dest from cache
  #   if not (res.hash of @selectFromOps)
  #     return

  #   params = @selectFromOps[res.hash]
  #   delete @selectFromOps[res.hash]

  #   params.dest.emptySilent()

  #   # set dest coll as coll cache, copy orm properties
  #   params.dest.ormType = params.coll.ormType
  #   params.dest.ormName = params.coll.ormName
  #   params.dest.ormParent = params.coll.ormParent

  #   @fillArray(params.dest, res.coll, params.ormType)

  #   if !!params.success
  #     params.success()

  # onNetSelectFromFail: (status) =>
  #   console.log('onNetSelectFromFail')
  #   console.log(status)

  # Helpers

  isCollectionLazy: (coll) ->
    names = getOrmNames(coll)

    if names[0] isnt 'world'
      return false

    params = @getParams(names)
    return @isArrayLazy(params)

  getParams: (names) ->
    fields = @structs['World']
    params = null
    for name in names
      if name is 'world'
        continue
      params = fields[name]
      fields = @structs[params.type]
    return params

