
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
    @ormName = name
    @ormParent = parent


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

# class ns.OrmField
# 
#   constructor: (name, type, params) ->
#     @name = name
#     @type = type
#     @params = params
# 
# class ns.OrmStruct
# 
#   constructor: (name, fields) ->
#     @name = name
#     @fields = fields

# Change, validate values of types OrmValue, OrmList
# Send/receive datao by Net
class ns.Orm

  constructor: ->
    # map struct name to params (fields, create structClass method)
    @srtucts = {}

    @validator = new ns.Validator()

  load: (callback) ->
    @loadCallback = callback
    ns.net.get('/load', @onLoadSuccess, @onLoadFail)

  addStruct: (struct) ->
    # add struct

  init: ->
    # parse all structs

  # Validate value
  
  validate: (obj) ->
    names = getOrmNames(obj)

    # obj maybe struct, list or value
    
    # need struct or struct, field name to get validate params
    
    # validate obj

  # work with structs

  setValue: (obj) ->
    names = getOrmNames(obj)

    # validate
    
    # change referenced values
    
    # send changes by net

  insert: (obj) ->
    names = getOrmNames(obj)

    # validate
    # change referenced values
    # send changes by net

  append: (obj) ->
    names = getOrmNames(obj)

    # validate
    # change referenced values
    # send changes by net

  insertAfter: (obj, after) ->
    names = getOrmNames(obj)

    # validate
    # change referenced values
    # send changes by net

  insertBefore: (obj, before) ->
    names = getOrmNames(obj)

    # validate
    # change referenced values
    # send changes by net

  remove: (obj) ->
    names = getOrmNames(obj)

    # change referenced values
    # send changes by net

  # events

  onLoadSuccess: (response) =>
    # parse all response
    # call callback
    @loadCallback()

  onLoadFail: (status) =>
