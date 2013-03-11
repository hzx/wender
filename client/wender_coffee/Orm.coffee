
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
- ref:'structName.collName' contains only id's, may be ordered,
- link:'structName.collName' contains only id's, work like ordered copy
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
    @rawSrtucts = {}

    @validator = new ns.Validator()

    @world = null

    @paramToValidate = {
      'maxLength': @validator.maxLength,
      'lt': @validator.lt,
      'lte': @validator.lte,
      'gt': @validator.gt,
      'gte': @validator.gte,
      'regex': @validator.regex
    }

  load: (world, callback) ->
    @world = world
    @loadCallback = callback
    ns.net.get('/load', @onLoadSuccess, @onLoadFail)

  addStructs: (structs) ->
    @rawStructs = structs

  # st - array of struct name, fields
  addStruct: (st) ->
    # add struct

  init: ->
    # parse all structs

  # Validate value
  
  validate: (obj) ->
    parent = obj.ormParent

    # obj maybe struct, list or value
    
    # need struct or struct, field name to get validate params
    
    # validate obj

  # work with structs


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
    console.log 'orm.selectSum'
    console.log coll

  update: (coll, vals, whereFn) ->
    console.log 'orm.update'
    console.log coll

  deleteFrom: (coll, whereFn) ->
    console.log 'orm.deleteFrom'
    console.log coll

  getImageUrl: (filename) ->
    if filename.value.length > 0
      '/static/img/' + filename.value
    else
      ''

  getThumbUrl: (filename) ->
    if filename.value.length > 0
      '/static/img/thumb_' + filename.value
    else
      ''

  # events

  onLoadSuccess: (response) =>
    # parse all response
    parsed = JSON.parse(response)
    # set net xsrf
    ns.net.setXsrf(parsed.xsrf)
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
    console.log 'Orm.onInsert'
    # validate
    # change referenced values
    # send changes by net

  onAppend: (obj) =>
    console.log 'Orm.onAppend'

  onInsertAfter: (obj, after) =>
    console.log 'Orm.onInsertAfter'

    # validate
    # change referenced values
    # send changes by net

  onInsertBefore: (obj, before) =>
    console.log 'Orm.onInsertBefore'
    # validate
    # change referenced values
    # send changes by net

  onRemove: (obj) =>
    console.log 'Orm.onRemove'

