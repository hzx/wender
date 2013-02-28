

class OrmField(object):

  def __init__(self, name, kind, params):
    self.name = name
    self.kind = kind
    self.params = params

class OrmStruct(object):

  def __init__(self, name, fields):
    self.name = name
    self.fields = {}
    for field in fields
      self.fields[field.name] = field

class Orm(object):

  def __init__(self):
    self.structs = {}

  def addStruct(self, struct):

  def parseParams(self, struct, field)

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

