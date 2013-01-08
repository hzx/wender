

# Base class for struct with id
class ns.HashStruct

  setHash: (hash) ->
    # set value directly
    @id.value = hash

  getHash: ->
    @id.value

  addHashListener: (listener) ->
    @id.addListener(listener)

  removeHashListener: (listener) ->
    @id.removeListener(listener)

class ns.OrmField

  constructor: (name, type, params) ->
    @name = name
    @type = type
    @params = params

class ns.OrmStruct

  constructor: (name, fields) ->
    @name = name
    @fields = fields

# Change, validate values of types OrmValue, OrmList
# Send/receive datao by Net
class ns.Orm

  constructor: ->
    # map struct name to OrmStruct
    @srtucts = {}
    # map structName.fieldName to params
    @fields = {}
    # map structName.fieldName to validator functions array.
    @fieldValidates = {}

  addStruct: (struct) ->
    # add struct

  init: ->
    # parse all structs

  # Validate value
  
  validate: (value) ->

  # work with structs

  setValue: (name, value) ->
    # validate
    # send changes by net

  insert: (name, obj) ->

  append: (name, obj) ->

  insertAfter: (name, obj, after) ->

  insertBefore: (name, obj, before) ->

  remove: (name, hash) ->
