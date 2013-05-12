

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
    self.colls = []
    # relations
    self.collToLinks = {}
    self.collToRefs = {}
    self.refToColl = {}
    self.linkToColl = {}

    self.docs = self.parseStructs(structs)
    self.createRelations()

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

  def createRelations(self):
    # walk through World
    fields = self.getStruct('World')
    collTree = self.searchCollsInStruct(fields)
    rawRefs = self.parseRelations(self.searchRefsInStruct(fields))
    rawLinks = self.parseRelations(self.searchLinksInStruct(fields))
    collToRefs = self.parseCollToRefs(rawRefs)
    collToLinks = self.parseCollToLinks(rawLinks)
    colls = self.parseColls(collTree)
    refToColl = self.parseRefToColl(rawRefs)
    linkToColl = self.parseLinkToColl(rawLinks)

    # collLinkNames = {}
    # for rawlink in links:
    #   link, coll = rawlink.split(':')
    #   names = link.split('.')

    """
    When delete collection, delete from links, refs.
    When delete link, delete from collection, refs.
    When delete link, delete from inner links, refs.
    """

    self.collToRefs = collToRefs
    self.collToLinks = collToLinks
    self.linkToColl = linkToColl
    self.colls = colls
    self.refToColl = refToColl

    # # search inner links

    # # debug
    # print 'refs:'
    # for coll, refs in collToRefs.items():
    #   print coll
    #   print refs
    # print ''

    # print 'links:'
    # for coll, links in collToLinks.items():
    #   print coll
    #   print links
    # print ''

    # print 'colls:'
    # for coll in colls:
    #   print coll
    # print ''

    # print 'linkToColl:'
    # for link, coll in linkToColl.items():
    #   print '%s - %s' % (link, coll)

  def searchCollsInStruct(self, fields):
    colls = []
    for name, params in fields.items():
      if params['isValueType']: continue
      if params['isArray']:
        if ('ref' in params) or ('link' in params):
          continue
        colls.append({'kind': 'coll', 'name': name})
        childs = self.searchCollsInStruct(self.getStruct(params['type']))
        if len(childs) > 0:
          colls.append({'kind': 'struct', 'name': name, 'childs': childs})
      # we have struct type
      else:
        childs = self.searchCollsInStruct(self.getStruct(params['type']))
        if len(childs) > 0:
          colls.append({'kind': 'struct', 'name': name, 'childs': childs})
    return colls

  def searchRefsInStruct(self, fields):
    refs = []
    for name, params in fields.items():
      if params['isValueType']: continue
      if params['isArray']:
        ref = params.get('ref', None)
        if ref:
          refs.append({'kind': 'array', 'name': name, 'array': ref})
        structRefs = self.searchRefsInStruct(self.getStruct(params['type']))
        if len(structRefs) > 0:
          refs.append({'kind': 'struct', 'name': name, 'struct': structRefs})
      else:
        structRefs = self.searchRefsInStruct(self.getStruct(params['type']))
        if len(structRefs) > 0:
          refs.append({'kind': 'struct', 'name': name, 'struct': structRefs})
    return refs

  def searchLinksInStruct(self, fields):
    links = []
    for name, params in fields.items():
      if params['isValueType']: continue
      if params['isArray']:
        link = params.get('link', None)
        if link: links.append({'kind': 'array', 'name': name, 'array': link})
        if params['type'] == 'robject': continue
        structFields = self.getStruct(params['type'])
        structLinks = self.searchLinksInStruct(structFields)
        if len(structLinks) > 0:
          links.append({'kind': 'struct', 'name': name, 'struct': structLinks})
      else:
        structFields = self.getStruct(params['type'])
        structLinks = self.searchLinksInStruct(structFields)
        if len(structLinks) > 0:
          links.append({'kind': 'struct', 'name': name, 'struct': structLinks})
    return links

  def parseColls(self, items):
    buf = []
    for item in items:
      kind = item['kind']
      if kind == 'struct':
        names = self.parseColls(item['childs'])
        for name in names:
          buf.append("%s.%s" % (item['name'], name))
      elif kind == 'coll':
        buf.append(item['name'])
    return buf

  def parseRefToColl(self, refs):
    buf = {}
    for ref in refs:
      ref, coll = ref.split(':')
      buf[ref] = coll
    return buf

  def parseRelations(self, items):
    buf = []
    for item in items:
      if item['kind'] == 'struct':
        structNames = self.parseRelations(item['struct'])
        for name in structNames:
          buf.append("%s.%s" % (item['name'], name))
      elif item['kind'] == 'array':
        buf.append("%s:%s" % (item['name'], item['array']))
    return buf

  def parseCollToRefs(self, refs):
    collToRefs = {}
    for rawref in refs:
      ref, coll = rawref.split(':')
      stored = collToRefs.get(coll, None)
      if stored:
        if not (ref in stored):
          stored.append(ref)
      else:
        collToRefs[coll] = [ref]

      self.refToColl[ref] = coll
    return collToRefs

  def parseCollToLinks(self, links):
    collToLinks = {}
    for rawlink in links:
      link, coll = rawlink.split(':')
      stored = collToLinks.get(coll, None)
      if stored:
        if not (link in stored):
          stored.append(link)
      else:
        collToLinks[coll] = [link]

      self.linkToColl[link] = coll
    return collToLinks

  def parseLinkToColl(self, rawlinks):
    links = {}
    for raw in rawlinks:
      link, coll = raw.split(':')
      links[link] = coll
    return links

  # def searchLinkRefs(self):
  #   """
  #   For every world array field search refs, links.
  #   """
  #   fields = self.getStruct('World')
  #   for name, params in fields.items():
  #     if params.isArray:
  #       if ('ref' in params) or ('link' in params): continue
  #       self.searchCollLinkRefs(name, fields)

  # def searchCollLinkRefs(self, coll, fields):
  #   """
  #   In every struct field search refs, links.
  #   """
  #   for name, params in fields.items():
  #     if params.isValueType: continue
  #     if params.isArray:
  #       if 'ref' in params:
  #         continue
  #       elif 'link' in params:
  #         continue
  #     # search in struct field
  #     structFields = getStruct(params.type)
  #     self.searchCollLinkRefs(coll, structFields)

