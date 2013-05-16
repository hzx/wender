from wender import mongodb
from wender import dbmeta
from wender import db as dbutil
import re
from pytils.translit import slugify


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
      if params['isValueType'] or params['isArray']: continue

      collobj = mongodb.selectOne(name, {})
      if collobj: continue

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
      raise Exception('getDefaultFieldValue: dont know default value to type "%s"' % paramtype)
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
    accessWriteRe = accessre['write']

    for docname, params in self.meta.docs.items():
      access = params.get('access', '----')
      if not accessReadRe.match(access): continue

      if params['isArray']:
        if self.isArrayLazy(params): continue
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
      if 'parentname' in cursor: names.append(cursor['parentname'])
      names.append(cursor['name'])
      if cursor['kind'] == 'value': break
      cursor = cursor.get('child', None)
    return names

  def getSeqValue(self, seq):
    value = None
    cursor = seq
    while cursor:
      if cursor['kind'] == 'value': value = cursor
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
      names.append(cursor['name'])
      if cursor is lastList: break
      cursor = cursor.get('child', None)

    return names


  def append(self, coll, obj, parent):
    names = self.collToNames(coll)
    if not names: return None

    dotcoll = '.'.join(names)

    # just add id
    if dotcoll in self.meta.refToColl:
      self.appendIdToRefLink(names, obj['id'], parent)
      return obj['id']
        
    # add obj to coll and id to link
    elif dotcoll in self.meta.linkToColl:
      # append obj to src coll
      src = self.meta.linkToColl[dotcoll]
      slug = self.setSlug(names, obj)
      newid = mongodb.insert(src, obj)

      # append to link id
      self.appendIdToRefLink(names, newid, parent)
      return newid
    # add obj to coll
    elif dotcoll in self.meta.colls:
      slug = self.setSlug(names, obj)
      newid = mongodb.insert(dotcoll, obj)
      return newid

    else:
      raise Exception('unknown collection type "%s"' % dotcoll)

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

      slugs = self.updateSlug([coll], field, value['value'])
      values = {field: value['value']}
      if slugs: values[slugs[0]] = slugs[1]
    
      mongodb.update(coll, values, {'id': value['parentid']})

    # list update
    else:
      # print 'list update'

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

  def insert(self, coll, obj):
    names = self.collToNames(coll)
    if not names: return None
    slug = self.setSlug(names, obj)
    print 'slug: ' + str(slug)
    return self.append(names[0], obj)

  def insertBefore(self, coll, obj, parent, before):
    """
    For ref and link.
    """
    names = self.collToNames(coll)
    if not names: return None

    dotcoll = '.'.join(names)

    # just add id
    if dotcoll in self.meta.refToColl:
      self.insertBeforeToRefLink(names, obj['id'], parent, before)
      return obj['id']

    # add obj to coll and id to link
    elif dotcoll in self.meta.linkToColl:
      # append obj to src coll
      src = self.meta.linkToColl[dotcoll]
      slug = self.setSlug(names, obj)
      print 'slug: ' + str(slug)
      newid = mongodb.insert(src, obj)

      # insert to link id
      self.insertBeforeToRefLink(names, obj['id'], parent, before)
      return newid

    # add obj to coll
    elif dotcoll in self.meta.colls:
      slug = self.setSlug(names, obj)
      print 'slug: ' + str(slug)
      newid = mongodb.insert(dotcoll, obj)
      return newid

    else:
      raise Exception('unknown collection type "%s"' % dotcoll)

  def insertAfter(self, coll, obj, parent, after):
    """
    For ref and link.
    """
    names = self.collToNames(coll)
    if not names: return None
    pass

  def selectOne(self, coll, where):
    names = self.collToNames(coll)
    if not names: return None

    return mongodb.selectOne(coll, where)

  def getSrcColl(self, names):
    dotcoll = '.'.join(names)
    if dotcoll in self.meta.refToColl:
      return self.meta.refToColl[dotcoll]
    if dotcoll in self.meta.linkToColl:
      return self.meta.linkToColl[dotcoll]
    if dotcoll in self.meta.colls:
      return dotcoll
    return None

  def selectFrom(self, coll, where, parent):
    names = self.collToNames(coll)
    if not names: return None

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
      return dbutil.cursorToList(mongodb.selectFrom(dotcoll, where))

    print 'refs:'
    print repr(self.meta.refToColl)
    print 'links:'
    print repr(self.meta.linkToColl)
    print 'colls:'
    print repr(self.meta.colls)
    raise Exception('unknown collection type "%s"' % dotcoll)

  def update(self, coll, values, where):
    names = self.collToNames(coll)
    if not names: return None

    return mongodb.update(coll, values, where)

  def delete(self, coll, objid, parentid):
    names = self.collToNames(coll)
    if not names: return None

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
      mongodb.delete(src, {'id': objid})
    # just coll
    elif dotcoll in self.meta.colls:
      # delete from coll
      mongodb.delete(dotcoll, {'id': objid})
    else:
      raise Exception('unknown collection type "%s"' % dotcoll)

  def updateImage(self, field, img, id):
    # get field
    # delete old field if exists
    # update field
    # return image filename

    # debug
    print 'updateImage not implemented'

  # HELPERS

  def appendIdToRefLink(self, collNames, objid, parentid):
    if not parentid: raise Exception('append to ref, link must provide parent id')

    parentNames = collNames[:-1]
    if len(parentNames) == 1:
      parentColl = parentNames[0]
    else:
      parentColl = self.getSrcColl(parentNames)
    fieldName = collNames[len(collNames)-1]

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
    if not parentid: raise Exception('insert to ref, link must provide parent id')

    parentNames = names[:-1]
    if len(parentNames) == 1:
      parentColl = parentNames[0]
    else:
      parentColl = self.getSrcColl(parentNames)
    fieldName = names[len(names)-1]

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
    if not parentid: raise Exception('select from ref, link must provide parent id')

    parentNames = collNames[:-1]
    if len(parentNames) == 1:
      parentColl = parentNames[0]
    else:
      parentColl = self.getSrcColl(parentNames)
    fieldName = collNames[len(collNames)-1]

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
    if not parentid: raise Exception('delete from ref, link must provide parent id')

    parentNames = names[:-1]
    if len(parentNames) == 1:
      parentColl = parentNames[0]
    else:
      parentColl = self.getSrcColl(parentNames)
    fieldName = names[len(names)-1]

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
    if slugs: values[slugs[0]] = slugs[1]

    mongodb.update(coll, values, {'id': val['parentid']})

  def setSlug(self, names, obj):
    """
    Find slug field and set it
    Return generated slug or None is slug not exists
    """
    # get obj type
    fields = self.meta.getCollType(names)
    if not fields: return None

    # search slug field name
    slugName = None
    for name, params in fields.items():
      if 'slug' in params:
        slugName = name
        break
    if not slugName: return None

    # get slug src
    slugSrc = fields[slugName]['slug']

    # gen slug from src
    src = obj.get(slugSrc, None)
    if not src: return None
    slug = slugify(src)

    # set slug
    obj[slugName] = slug

    return slug

  def updateSlug(self, names, field, value):
    # get coll type
    fields = self.meta.getCollType(names)
    if not fields: return None

    # search slug field name
    slugName = None
    for name, params in fields.items():
      if 'slug' in params:
        slugName = name
        break
    if not slugName: return None

    # get slug src
    slugSrc = fields[slugName]['slug']

    # slug src must be equal to field
    if slugSrc != field: return None

    # gen slug
    slug = slugify(value)

    return [slugName, slug]
