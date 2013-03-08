

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
    self.structs = {}

    for st in structs:
      self.addStruct(st)

  def addStruct(self, st):
    pass

  def parseParams(self, st, field):
    pass

  # db operations

  def load(self, userKind):
    """
    Load database for userKind
    """
    pass

  def append(self):
    pass

  def insert(self):
    pass

  def insertBefore(self):
    pass

  def insertAfter(self):
    pass

  def selectFrom(self):
    pass

  def update(self):
    pass

  def delete(self):
    pass

