

class ns.World extends ns.OrmStruct

  constructor: (type, name, parent) ->
    super(type, name, parent)

  load: (url, modelNs, callback) ->
    ns.orm.load(url, modelNs, this, callback)

  validate: (obj) ->
    ns.orm.validate(ob)

  getImageUrl: (filename) ->
    return ns.orm.getImageUrl(filename)

  getThumbUrl: (filename) ->
    return ns.orm.getThumbUrl(filename)

  uploadFiles: (url, fieldName, files, success, fail) ->
    ns.net.uploadFiles(url, fieldName, files, "[]", success, fail)

  updateImage: (field, file) ->
    ns.orm.updateImage(field, file, success, fail)

  insertImages: (field, files, success, fail) ->
    ns.orm.insertImages(field, files, success, fail)
