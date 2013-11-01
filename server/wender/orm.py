from wender import mongodb
from wender import dbmeta
from wender import db as dbutil
import re
from pytils.translit import slugify
from wender.utils import image as uimage
import os.path
import os
import uuid
from tornado.options import options


class OrmField(object):
  def __init__(self, name, kind, params):
    self.name = name
    self.kind = kind
    self.params = params


class OrmStructMeta(object):
  def __init__(self, name, fields):
    self.name = name
    self.fields = self.parseFields(fields)

  def parseFields(fields):
    fields = {}
    for field in fields:
      fields[field.name] = field
    return fields


# TODO(dem) check structs meta before operations
class Orm(object):
  def __init__(self, structs):
    self.meta = dbmeta.DbMeta(structs)

    self.accessToRe = {
      'user': {
        'read': re.compile('.{2}([r])'),
        'write': re.compile('.{3}([w])'),
      },
      'admin': {
        'read': re.compile('.*'),
        'write': re.compile('.*'),
      },
    }

    self.createIndexes()
    self.createBase()

  # TODO(dem) move ensureIndexes and ensureBase to riffler
  # TODO(dem) find all indexes in struct, replace it
  def createIndexes(self):
    for coll in self.meta.colls:
      names = coll.split('.')
      collName = names[0]
      buf = names[1:]
      buf.append('id')
      indexName = '.'.join(buf)
      mongodb.createIndex(collName, indexName)

  # create base structures in db
  def createBase(self):
    """
    For each field in the world structure create default object
    with default fields
    """
    fields = self.meta.getStruct('World')
    for name, params in fields.items():
      if params['isValueType'] or params['isArray']:
        continue

      collobj = mongodb.selectOne(name, {})
      if collobj:
        continue

      # if default object not found, create it
      default = self.composeDefaultObject(params['type'])

      mongodb.insert(name, default)

  def composeDefaultObject(self, structName):
    fields = self.meta.getStruct(structName)
    dummy = {}
    for name, params in fields.items():
      dummy[name] = self.getDefaultFieldValue(params)
    return dummy

  def getDefaultFieldValue(self, params):
    paramtype = params['type']

    # value type
    if params['isValueType']:
      if paramtype == 'int':
        return 0
      if paramtype == 'float':
        return 0.0
      if paramtype == 'string':
        return ''
      raise Exception(
        'getDefaultFieldValue: dont know default value to type "%s"'
        % paramtype)
    # array type
    if params['isArray']:
      return []

    # struct type
    return self.composeDefaultObject(params['type'])

  # image operations
  def getImageSizes(self, name):
    pass

  # db operations

  def load(self, useraccess):
    """
    Load database for userKind
    """
    db = {}

    accessre = self.accessToRe[useraccess]
    accessReadRe = accessre['read']
    # accessWriteRe = accessre['write']

    for docname, params in self.meta.docs.items():
      access = params.get('access', '----')
      if not accessReadRe.match(access):
        continue

      if params['isArray']:
        if self.isArrayLazy(params):
          continue
        db[docname] = dbutil.cursorToList(mongodb.selectFrom(docname, {}))
      else:
        db[docname] = mongodb.selectOne(docname, {})
    return db

  def isArrayLazy(self, params):
    if 'ref' in params:
      world = self.meta.getStruct('World')
      params = world[params['ref']]
    if 'link' in params:
      world = self.meta.getStruct('World')
      params = world[params['link']]
    return params.get('lazy', True)

  def op(self, tasks):
    """
    Parse tasks and perform operations on db and files.
    """
    pass

  def collToNames(self, coll):
    """
    Split by . coll and remove first part world
    """
    names = coll.split('.')
    if (len(names) <= 1) and (names[0] != 'world'):
      return None
    return names[1:]

  def seqToNames(self, seq):
    cursor = seq
    names = []
    while cursor:
      if 'parentname' in cursor:
        names.append(cursor['parentname'])
      names.append(cursor['name'])
      if cursor['kind'] == 'value':
        break
      cursor = cursor.get('child', None)
    return names

  def getSeqValue(self, seq):
    value = None
    cursor = seq
    while cursor:
      if cursor['kind'] == 'value':
        value = cursor
      cursor = cursor.get('child', None)
    return value

  def getLastList(self, seq):
    """
    Find last list names
    """
    lastList = None

    cursor = seq
    while cursor:
      if cursor['kind'] == 'list':
        lastList = cursor
      cursor = cursor.get('child', None)

    return lastList

  def getLastListNames(self, seq, lastList):
    names = []

    cursor = seq
    while cursor:
      if cursor['name']:
        names.append(cursor['name'])
      if cursor is lastList:
        break
      cursor = cursor.get('child', None)

    return names

  def append(self, coll, obj, parent):
    names = self.collToNames(coll)
    if not names:
      return None

    dotcoll = '.'.join(names)

    # just add id
    if dotcoll in self.meta.refToColl:
      self.appendIdToRefLink(names, obj['id'], parent)
      return obj['id']

    # add obj to coll and id to link
    elif dotcoll in self.meta.linkToColl:
      # append obj to src coll
      src = self.meta.linkToColl[dotcoll]
      self.setSlug(names, obj)
      newid = mongodb.insert(src, obj)

      # append to link id
      self.appendIdToRefLink(names, newid, parent)
      return newid
    # add obj to coll
    elif dotcoll in self.meta.colls:
      self.setSlug(names, obj)
      newid = mongodb.insert(dotcoll, obj)
      return newid

    else:
      # try resolve inner coll
      # search parent coll without last names item
      parentColl = '.'.join(names[:-1])
      subColl = names[-1]
      if parentColl in self.meta.refToColl:
        src = self.meta.refToColl[parentColl]
        self.appendInnerColl(src, parent, subColl, obj)
      elif parentColl in self.meta.linkToColl:
        src = self.meta.linkToColl[parentColl]
        self.appendInnerColl(src, parent, subColl, obj)
      elif parentColl in self.meta.links:
        self.appendInnerColl(parentColl, parent, subColl, obj)
      else:
        raise Exception('unknown collection type "%s"' % dotcoll)

  def updateRaw(self, coll, values, wh):
    names = self.collToNames(coll)
    if not names:
      return None
    dotcoll = '.'.join(names)

    mongodb.update(dotcoll, values, wh)

  def setValue(self, seq):
    # parse sequences
    # print 'orm.setValue, seq:'
    # print repr(seq)

    # get last list
    lastList = self.getLastList(seq)

    # global update
    if not lastList:
      # print 'global update'

      names = self.seqToNames(seq)
      value = self.getSeqValue(seq)
      coll = names[0]
      field = names[1]

      # update slugs
      slugs = self.updateSlug([coll], field, value['value'])
      values = {field: value['value']}
      if slugs:
        values[slugs[0]] = slugs[1]

      # get value params
      fieldnames = coll + '.' + field
      params = self.meta.getValueParams(fieldnames)

      # if imageSizes in params - remove old image value
      if 'imageSizes' in params:
        # get object with field
        obj = mongodb.selectOne(coll, {'id': value['parentid']})
        filename = obj[field]
        self.deleteImage(filename, params)

      mongodb.update(coll, values, {'id': value['parentid']})

    # list update
    else:
      listNames = self.getLastListNames(seq, lastList)
      coll = '.'.join(listNames)

      # search src list and update
      # search src in refs
      if coll in self.meta.refToColl:
        # print 'update ref value:'
        # print coll
        src = self.meta.refToColl[coll]
        # print src
        self.updateListValue(src, seq, lastList)
      # search src in links
      elif coll in self.meta.linkToColl:
        # print 'update link value:'
        # print coll
        src = self.meta.linkToColl[coll]
        # print src
        self.updateListValue(src, seq, lastList)
      # search src in colls
      elif coll in self.meta.colls:
        # print 'update list value:'
        # print coll
        self.updateListValue(coll, seq, lastList)
      else:
        raise Exception('unknown list type "%s"' % str(coll))

  def insert(self, coll, obj, parent):
    # names = self.collToNames(coll)
    # if not names:
    #   return None
    # self.setSlug(names, obj)
    # return self.append(names[0], obj, parent)
    return self.append(coll, obj, parent)

  def insertBefore(self, coll, obj, parent, before):
    """
    For ref and link.
    """
    names = self.collToNames(coll)
    if not names:
      return None

    dotcoll = '.'.join(names)

    # just add id
    if dotcoll in self.meta.refToColl:
      self.insertBeforeToRefLink(names, obj['id'], parent, before)
      return obj['id']

    # add obj to coll and id to link
    elif dotcoll in self.meta.linkToColl:
      # append obj to src coll
      src = self.meta.linkToColl[dotcoll]
      self.setSlug(names, obj)
      newid = mongodb.insert(src, obj)

      # insert to link id
      self.insertBeforeToRefLink(names, obj['id'], parent, before)
      return newid

    # add obj to coll
    elif dotcoll in self.meta.colls:
      self.setSlug(names, obj)
      newid = mongodb.insert(dotcoll, obj)
      return newid

    else:
      raise Exception('unknown collection type "%s"' % dotcoll)

  def insertAfter(self, coll, obj, parent, after):
    """
    For ref and link.
    """
    names = self.collToNames(coll)
    if not names:
      return None
    pass

  def getSrcColl(self, names):
    dotcoll = '.'.join(names)
    if dotcoll in self.meta.refToColl:
      return self.meta.refToColl[dotcoll]
    if dotcoll in self.meta.linkToColl:
      return self.meta.linkToColl[dotcoll]
    if dotcoll in self.meta.colls:
      return dotcoll
    return None

  def selectOne(self, coll, where):
    names = self.collToNames(coll)
    if not names:
      return None
    dotcoll = '.'.join(names)

    if dotcoll in self.meta.refToColl:
      src = self.meta.refToColl[dotcoll]
      return mongodb.selectOne(src, where)
    elif dotcoll in self.meta.linkToColl:
      src = self.meta.linkToColl[dotcoll]
      return mongodb.selectOne(src, where)
    elif dotcoll in self.meta.colls:
      return mongodb.selectOne(dotcoll, where)
    return None

  def selectFrom(self, coll, where, parent, limit=None):
    names = self.collToNames(coll)
    if not names:
      return None

    dotcoll = '.'.join(names)

    # load reflink
    if dotcoll in self.meta.refToColl:
      src = self.meta.refToColl[dotcoll]
      return self.selectFromRefLink(src, names, where, parent)
    elif dotcoll in self.meta.linkToColl:
      src = self.meta.linkToColl[dotcoll]
      return self.selectFromRefLink(src, names, where, parent)
    # load array
    elif dotcoll in self.meta.colls:
      return dbutil.cursorToList(mongodb.selectFrom(dotcoll, where, limit))

    raise Exception('unknown collection type "%s"' % dotcoll)

  def update(self, coll, values, where):
    names = self.collToNames(coll)
    if not names:
      return None

    return mongodb.update(coll, values, where)

  def deleteWhere(self, coll, where):
    names = self.collToNames(coll)
    dotcoll = '.'.join(names)

    items = mongodb.selectFrom(dotcoll, where)
    ids = []
    for item in items:
      ids.append(item['id'])
      self.deleteCollItem(dotcoll, item['id'])
    return ids

  def delete(self, coll, objid, parentid):
    names = self.collToNames(coll)
    if not names:
      return None

    dotcoll = '.'.join(names)

    # coll is ref
    if dotcoll in self.meta.refToColl:
      # delete id from ref array
      self.deleteRefLink(names, objid, parentid)
    # coll is link
    elif dotcoll in self.meta.linkToColl:
      # delete id from link array
      self.deleteRefLink(names, objid, parentid)
      # delete from coll
      src = self.meta.linkToColl[dotcoll]
      # mongodb.delete(src, {'id': objid})
      self.deleteCollItem(src, objid)
    # just coll
    elif dotcoll in self.meta.colls:
      # delete from coll
      # mongodb.delete(dotcoll, {'id': objid})
      self.deleteCollItem(dotcoll, objid)
    else:
      # try resolve inner coll
      # search parent coll without last names item
      parentColl = '.'.join(names[:-1])
      subColl = names[-1]
      if parentColl in self.meta.refToColl:
        src = self.meta.refToColl[parentColl]
        self.deleteFromInnerColl(src, parentid, subColl, objid)
      elif parentColl in self.meta.linkToColl:
        src = self.meta.linkToColl[parentColl]
        self.deleteFromInnerColl(src, parentid, subColl, objid)
      elif parentColl in self.meta.colls:
        self.deleteFromInnerColl(parentColl, parentid, subColl, objid)
      else:
        # if nothing found
        raise Exception('unknown collection type "%s"' % dotcoll)

  def saveImages(self, field, imgs, imagePath):
      """
      Return saved images
      """
      saved = []
      # get field params
      params = self.meta.getFieldParams(field)
      if not params:
          return None
      imageSizes = params.get('imageSizes', None)
      imageCrop = params.get('imageCrop', False)
      thumbSizes = params.get('thumbSizes', None)
      thumbCrop = params.get('thumbCrop', None)
      # save files
      for img in imgs:
          # get from src filename extension
          srcname, srcext = os.path.splitext(img['filename'])
          # generate filename
          filename = str(uuid.uuid4()) + srcext
          # compose filepath
          filepath = os.path.join(imagePath, filename)
          # save original image
          with open(filepath, 'w') as f:
            f.write(img['body'])
          # add filename to saved
          saved.append(filename)
          # generate for imageSizes
          if imageSizes:
              for sz in imageSizes:
                  # generate sized image filename
                  imagepath = os.path.join(
                      imagePath,
                      "%s_%s" % (sz, filename))
                  nums = sz.split('x')
                  if imageCrop:
                      uimage.createResizedImageCrop(
                          filepath, imagepath,
                          (int(nums[0]), int(nums[1])))
                  else:
                      uimage.createResizedImage(
                          filepath, imagepath,
                          (int(nums[0]), int(nums[1])))
          # generate for thumbSizes
          if thumbSizes:
              for sz in thumbSizes:
                  # generate sized thumb filename
                  thumbpath = os.path.join(
                      imagePath,
                      "%s_%s" % (sz, filename))
                  nums = sz.split('x')
                  if thumbCrop:
                      uimage.createResizedImageCrop(
                          filepath, thumbpath,
                          (int(nums[0]), int(nums[1])))
                  else:
                      uimage.createResizedImage(
                          filepath, thumbpath,
                          (int(nums[0]), int(nums[1])))
      return saved

  # HELPERS

  def appendIdToRefLink(self, collNames, objid, parentid):
    if not parentid:
      raise Exception('append to ref, link must provide parent id')

    parentNames = collNames[:-1]
    if len(parentNames) == 1:
      parentColl = parentNames[0]
    else:
      parentColl = self.getSrcColl(parentNames)
    fieldName = collNames[len(collNames) - 1]

    # get parent object
    parentObj = mongodb.selectOne(parentColl, {'id': parentid})

    # get ids field
    idsField = parentObj[fieldName]

    # add id to ids field
    if not (objid in idsField):
      idsField.append(objid)
      # update ids field
      mongodb.update(parentColl, {fieldName: idsField}, {'id': parentid})

  def insertBeforeToRefLink(self, names, objid, parentid, beforeid):
    if not parentid:
      raise Exception('insert to ref, link must provide parent id')

    parentNames = names[:-1]
    if len(parentNames) == 1:
      parentColl = parentNames[0]
    else:
      parentColl = self.getSrcColl(parentNames)
    fieldName = names[len(names) - 1]

    # get parent object
    parent = mongodb.selectOne(parentColl, {'id': parentid})

    # get ids field
    idsField = parent[fieldName]

    # add id before beforeid
    if (beforeid in idsField):
      beforeIndex = idsField.index(beforeid)
      # insert in index position (before)
      idsField.insert(beforeIndex, objid)
      # update ids field
      mongodb.update(parentColl, {fieldName: idsField}, {'id': parentid})

  # TODO(dem) implement
  def selectFromRefLink(self, src, collNames, where, parentid):
    if not parentid:
      raise Exception('select from ref, link must provide parent id')

    parentNames = collNames[:-1]
    if len(parentNames) == 1:
      parentColl = parentNames[0]
    else:
      parentColl = self.getSrcColl(parentNames)
    fieldName = collNames[len(collNames) - 1]

    # get parent object
    parentObj = mongodb.selectOne(parentColl, {'id': parentid})

    # get ids field
    idsField = parentObj[fieldName]

    # get coll with ids
    items = []
    for curr in idsField:
      item = mongodb.selectOne(src, {'id': curr})
      items.append(item)
    # items = mongodb.selectFrom(src, {'id':{'$in': idsField}})

    return items
    # return dbutil.cursorToList(items)

  def deleteRefLink(self, names, objid, parentid):
    if not parentid:
      raise Exception('delete from ref, link must provide parent id')

    parentNames = names[:-1]
    if len(parentNames) == 1:
      parentColl = parentNames[0]
    else:
      parentColl = self.getSrcColl(parentNames)
    fieldName = names[len(names) - 1]

    # get parent object
    parentObj = mongodb.selectOne(parentColl, {'id': parentid})

    # get ids field
    idsField = parentObj[fieldName]

    # remove id from idsField
    if objid in idsField:
      idsField.remove(objid)
      # update ids field
      mongodb.update(parentColl, {fieldName: idsField}, {'id': parentid})

  def updateListValue(self, coll, seq, lastList):
    val = lastList['child']
    values = {val['name']: val['value']}

    slugs = self.updateSlug(coll.split('.'), val['name'], val['value'])
    if slugs:
      values[slugs[0]] = slugs[1]

    mongodb.update(coll, values, {'id': val['parentid']})

  def setSlug(self, names, obj):
    """
    Find slug field and set it
    Return generated slug or None is slug not exists
    """
    # get obj type
    fields = self.meta.getCollType(names)
    if not fields:
      return None

    # search slug field name
    slugName = None
    for name, params in fields.items():
      if 'slug' in params:
        slugName = name
        break
    if not slugName:
      return None

    # get slug src
    slugSrc = fields[slugName]['slug']

    # gen slug from src
    src = obj.get(slugSrc, None)
    if not src:
      return None
    slug = slugify(src)

    # set slug
    obj[slugName] = slug

    return slug

  def updateSlug(self, names, field, value):
    # get coll type
    fields = self.meta.getCollType(names)
    if not fields:
      return None

    # search slug field name
    slugName = None
    for name, params in fields.items():
      if 'slug' in params:
        slugName = name
        break
    if not slugName:
      return None

    # get slug src
    slugSrc = fields[slugName]['slug']

    # slug src must be equal to field
    if slugSrc != field:
      return None

    # gen slug
    slug = slugify(value)

    return [slugName, slug]

  def updateObjIds(self, coll, obj):
    """
    Search inner fields and update id
    """
    # from coll get obj struct fields
    # for each field search id name
    pass

  def deleteFromInnerColl(self, coll, parentId, field, objid):
    """
    In coll object with parentId search array field and remove objid.
    """
    # get parent object
    parentObj = mongodb.selectOne(coll, {'id': parentId})
    # get coll fields
    parentFields = self.meta.getCollType(coll.split('.'))
    # get inner coll fields
    innerFields = self.meta.getStruct(parentFields[field]['type'])
    # get field
    arr = parentObj[field]
    # from arr remove objid element
    index = -1
    for i, item in enumerate(arr):
      if item['id'] == objid:
        index = i
        break
    # if index not found just return
    if index == -1:
      return

    # remove images from item
    item = arr[index]
    for name, params in innerFields.items():
      if 'imageSizes' in params:
        filename = item[name]
        self.deleteImage(filename, params)
    # remove element from arr
    arr.pop(index)
    # update parentObj
    mongodb.update(coll, {field: arr}, {'id': parentId})

  def appendInnerColl(self, coll, parentId, field, obj):
    """
    In coll object with parentId search array field and append obj.
    """
    print coll
    print parentId
    print field
    print repr(obj)
    # get parent object
    parentObj = mongodb.selectOne(coll, {'id': parentId})
    # get field
    arr = parentObj[field]
    # to arr add obj
    arr.append(obj)
    # update parentObj
    mongodb.update(coll, {field: arr}, {'id': parentId})

  def deleteCollItem(self, coll, itemId):
    """
    Do work in 2 stages:
      1. search what to do
      2. process search result
    Delete inner arrays.
    Delete images.
    """
    # store search results of [name, params]
    imageFields = []
    images = []
    # store search results of [name, params]
    links = []
    # store search results of name, name, ...
    internalColls = []

    # get coll type
    names = coll.split('.')
    fields = self.meta.getCollType(names)
    # search array field, image field in fields
    for name, params in fields.items():
      # found image by imageSizes
      if 'imageSizes' in params:
        imageFields.append([name, params])
        continue
      # found array field
      if params['isArray']:
        # ignore ref array
        if 'ref' in params:
          continue
        # for link save
        if 'link' in params:
          links.append([name, params])
          continue
        # for internal collection save
        else:
          internalColls.append(name)
          continue

    # get item from coll
    item = mongodb.selectOne(coll, {'id': itemId})

    for imgf in imageFields:
      imgfFilename = item[imgf[0]]
      imgfParams = fields[imgf[0]]
      images.append([imgfFilename, imgfParams])

    # process internalColls
    for collname in internalColls:
      intcoll = item[collname]
      # for each obj in intcoll search images
      collnames = names + [collname]
      collfields = self.meta.getCollType(collnames)
      # in coll fields search images
      for tmpname, tmpparams in collfields.items():
        # found image field
        if 'imageSizes' in tmpparams:
          # for every intcoll add images
          for tmpitem in intcoll:
            tmpfilename = tmpitem[tmpname]
            images.append([tmpfilename, tmpparams])


    # process images

    for image in images:
      filename = image[0]
      params = image[1]
      self.deleteImage(filename, params)

    # process links
    for link in links:
      linkname = link[0]
      linkparams = link[1]
      # get link ids from item
      ids = item[linkname]
      # get src coll
      src = linkparams['link']
      # delete from src coll for every id
      for linkid in ids:
        self.deleteCollItem(src, linkid)

    # delete from coll
    mongodb.delete(coll, {'id': itemId})

  def deleteImage(self, filename, params):
    srcFilename = os.path.join(options.imgpath, filename)
    if (not os.path.exists(srcFilename)) or ('refImage' in params):
      return

    # remove srcFilename
    self.deleteFile(srcFilename)

    # remove imageSizes
    if 'imageSizes' in params:
      imageSizes = params['imageSizes']
      for item in imageSizes:
        tmpfilename = os.path.join(options.imgpath, "%s_%s" % (item, filename))
        self.deleteFile(tmpfilename)

    # remove thumbSizes
    if 'thumbSizes' in params:
      thumbSizes = params['thumbSizes']
      for item in thumbSizes:
        tmpfilename = os.path.join(options.imgpath, "%s_%s" % (item, filename))
        self.deleteFile(tmpfilename)

  def deleteFile(self, filename):
    if os.path.exists(filename) and os.path.isfile(filename):
      os.remove(filename)

  def checkPaging(self, coll, wherePrev, whereNext):
    names = self.collToNames(coll)
    dotcoll = '.'.join(names)

    po = mongodb.selectOne(dotcoll, wherePrev)
    no = mongodb.selectOne(dotcoll, whereNext)
    return { 'prev': po != None, 'next': no != None}

