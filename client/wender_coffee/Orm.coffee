
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
- imageSizes:['1200x400', '2400x800']
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
    names.push(cursor.ormName)
    cursor = cursor.ormParent
  names.reverse()
  return names

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

# Change, validate values of types OrmValue, OrmList
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

  load: (url, modelNs, world, callback) ->
    @model = modelNs
    @world = world
    @loadCallback = callback
    ns.net.get(url, @onLoadSuccess, @onLoadFail)

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
      dest.append(field)

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
      field = rlobj.clone()
      dest.append(field)

  fillValue: (dest, data, valuetype) ->
    if (!! data) is false
      return null
    dest.setValue(data)

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
          @fillValue(dest[name], value, params.type)
        else
          @fillStruct(dest[name], value, params.type)

  setStructs: (structs) ->
    @structs = structs

  getFieldParams: (field) ->
    # take parent ormType
    ormtype = field.ormParent.ormType
    # search struct with ormtype
    st = @structs[ormtype]
    if !!st is false then return null

    params = st[field.ormName]
    if !!params is false then return null

    return params

  init: ->
    # parse all structs

  # Validate value
  
  validate: (obj) ->
    parent = obj.ormParent

    # obj maybe struct, list or value
    
    # need struct or struct, field name to get validate params
    
    # validate obj

  # work with structs

  # work with server orm

  # field must be dot_names
  updateImage: (field, file, success, fail) ->
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

  # CRUD OPERATIONS

  insert: (coll, val) ->
    coll.insert(val)

  insertAfter: (coll, val, whereFn) ->

  insertBefore: (coll, val, whereFn) ->

  selectCount: (coll) ->
    return coll.count

  selectOne: (coll, whereFn) ->
    return coll.first.clone()

  selectFrom: (dest, coll, whereFn, orderField, sortOrder) ->
    dest.empty()
    cursor = coll.first
    while cursor isnt null
      dest.append(cursor.obj.clone())
      cursor = cursor.next

  selectConcat: (dest, colls) ->
    dest.empty()
    for coll in colls
      cursor = coll.first
      while cursor isnt null
        dest.append(cursor.obj.clone())
        cursor = cursor.next

  selectSum: (coll, byField) ->
    sum = 0
    # console.log 'orm.selectSum'
    # console.log coll

  update: (coll, vals, whereFn) ->
    # console.log 'orm.update'
    # console.log coll

  deleteFrom: (coll, whereFn) ->
    # console.log 'orm.deleteFrom'
    # console.log coll

  getImageUrl: (filename) ->
    if filename.value.length is 0
      return ''

    params = @getFieldParams(filename)
    if params is null then return ''

    imageSizes = params.imageSizes
    if !!imageSizes is false
      return ''

    return '/static/img/' + imageSizes[0] + '_' + filename.value

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

  # event OrmList, OrmValue operations
  
  onSetValue: (obj) ->
    names = getOrmNames(obj)

    # validate
    
    # change referenced values
    
    # send changes by net

  
  onInsert: (obj) =>
    # console.log 'Orm.onInsert'
    # validate
    # change referenced values
    # send changes by net

  onAppend: (obj) =>
    # console.log 'Orm.onAppend'

  onInsertAfter: (obj, after) =>
    # console.log 'Orm.onInsertAfter'

    # validate
    # change referenced values
    # send changes by net

  onInsertBefore: (obj, before) =>
    # console.log 'Orm.onInsertBefore'
    # validate
    # change referenced values
    # send changes by net

  onRemove: (obj) =>
    # console.log 'Orm.onRemove'

