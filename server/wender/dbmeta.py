

indexOrderMap = {
    'asc': 1,
    'desc': -1,
  }


class DbIndex(object):

  def __init__(self, names, order):
    self.names = names
    self.order = indexOrderMap[order]
    self.value_types = ['bool', 'int', 'float', 'string', 'datetime']


class DbCollection(object):

  def __init__(self, name):
    self.name = name
    self.indexes = []


class DbMeta(object):

  def __init__(self, structs):
    self.structs = structs

    self.docs = self.parseStructs(structs)

  def parseStructs(self, structs):
    fields = self.getStruct('World')

    docs = {}

    # add docs
    # every fields of world is doc
    for name, params in fields.items():
      docs[name] = self.collectFields([], params)

    return docs

  def collectFields(self, parentNames, params):
    paramtype = params['type']
    # simple type field
    # if paramtype in self.value_types:
    return params

  def getStruct(self, name):
    fields = self.structs.get(name, None)
    if not fields:
      raise Exception('DbMeta: struct with name "%s" not found' % name)
    return fields

