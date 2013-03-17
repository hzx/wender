from wender import mongodb
from wender import dbmeta
from wender import db as dbutil
import re


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
        db[docname] = dbutil.cursorToList(mongodb.selectFrom(docname, {}))
      else:
        db[docname] = mongodb.selectOne(docname, {})
    return db

  def append(self):
    pass

  def insert(self, coll, values):
    return mongodb.insert(coll, values)

  def insertBefore(self):
    pass

  def insertAfter(self):
    pass

  def selectOne(self, coll, where):
    return mongodb.selectOne(coll, where)

  def selectFrom(self, coll, where):
    return mongodb.selectFrom(coll, where)

  def update(self, coll, values, where):
    return mongodb.update(coll, values, where)

  def delete(self, coll, where):
    return mongodb.delete(coll, where)

