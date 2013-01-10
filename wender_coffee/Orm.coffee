
# get array of orm names from parent to child
getOrmNames: (obj) ->
  names = []
  cursor = obj
  while obj.ormName isnt null
    names.push(obj.ormName)
    cursor = cursor.ormParent
  names.reverse()
  names

# base class for struct
class ns.OrmStruct

  constructor: (name, parent) ->
    @ormName = name
    @ormParent = parent


# Base class for struct with id
class ns.OrmHashStruct extends ns.OrmStruct

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

  # private
  

