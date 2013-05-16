from tornado.web import RequestHandler
from tornado.web import HTTPError
from tornado.web import authenticated
from wender.utils.mongodb import toJson
import json


class BaseHandler(RequestHandler):

  @property
  def orm(self):
    return self.application.orm

  # may stop processing if calls finish or send_error
  # def prepare(self):
  #   pass

  # render error pages
  def write_error(self, status_code, **kwargs):
    if status_code == 404:
      self.render('404.html')
    elif status_code >= 500 and status_code < 600:
      self.render('500.html')
    else:
      RequestHandler.write_error(status_code, kwargs)

  def get_current_user(self):
    userId = self.get_secure_cookie('user')
    if userId == None: return None

    # get user from db
    # return authModels.getUser(userId)

    return userId

  def get_user_locale(self):
    #if "locale" not in self.current_user.prefs:
    #  # Use the Accept-Language header
    #  return None
    #return self.current_user.prefs["locale"]

    # Use the Accept-Language header
    return None
  
  # def on_connection_close(self):
  #   pass

  def set_default_headers(self):
    self.set_header('Server', 'wender')

  def isXhr(self):
    return self.request.headers.get('X-Requested-With', None) == 'XMLHttpRequest'

  def writeJson(self, obj):
    self.set_header('Content-Type', 'application/json;charset=UTF-8')
    self.finish(toJson(obj))

class AppHandler(BaseHandler):

  def initialize(self, appName, title):
    self.appName = appName
    self.title = title

  def get(self):
    # load app template
    templateName = 'app-%s.html' % self.appName
    self.render(templateName, lang='ru', title=self.title, message=self.title)

class AppAdminHandler(BaseHandler):

  def initialize(self, appName, title):
    self.appName = appName
    self.title = title

  @authenticated
  def get(self):
    # load app template
    templateName = 'app-%s.html' % self.appName
    self.render(templateName, lang='ru', title=self.title, message=self.title)


class OrmLoadHandler(BaseHandler):

  def initialize(self, appName, useraccess):
    self.appName = appName
    self.useraccess = useraccess

  def get(self):
    if not self.isXhr():
      raise HTTPError(401)

    response = {
        'xsrf': self.xsrf_token,
        'data': self.orm.load(self.useraccess),
        'coll_to_refs': self.orm.meta.collToRefs,
        'coll_to_links': self.orm.meta.collToLinks,
        'link_to_coll': self.orm.meta.linkToColl,
        }

    # load orm data
    self.writeJson(response)

class OrmOpHandler(BaseHandler):

  def opValue(self):
    rawseq = self.get_argument('seq', None)
    if not rawseq: raise HTTPError(500, 'send seq parameter')

    seq = json.loads(rawseq)

    self.orm.setValue(seq)

    return {}


  def opInsert(self):
    coll = self.get_argument('coll', None)
    obj = self.get_argument('obj', None)
    parent = self.get_argument('parent', None)
    if (not coll) or (not obj): raise HTTPError(500)

    obj = json.loads(obj)

    oldid = obj['id']
    newid = self.orm.insert(coll, obj)

    return { 'coll': coll, 'oldid': oldid, 'newid': newid }

  def opInsertBefore(self):
    hsh = self.get_argument('hash', None)
    coll = self.get_argument('coll', None)
    obj = self.get_argument('obj', None)
    before = self.get_argument('before', None)
    parent = self.get_argument('parent', None)
    if (not coll) or (not obj) or (not before) or (not parent): raise HTTPError(500)

    obj = json.loads(obj)

    oldid = obj['id']
    newid = self.orm.insertBefore(coll, obj, parent, before)

    return { 'hash': hsh, 'coll': coll, 'oldid': oldid, 'newid': newid, 'before': before }

  def opInsertAfter(self):
    hsh = self.get_argument('hash', None)
    coll = self.get_argument('coll', None)
    obj = self.get_argument('obj', None)
    after = self.get_argument('after', None)
    parent = self.get_argument('parent', None)
    if (not coll) or (not obj) or (not after) or (not parent): raise HTTPError(500)

    obj = json.loads(obj)

    oldid = obj['id']
    newid = self.orm.insertAfter(coll, obj, parent, after)

    return { 'hash': hsh, 'coll': coll, 'oldid': oldid, 'newid': newid, 'after': after }

  def opAppend(self):
    # get coll
    coll = self.get_argument('coll', None)
    hsh = self.get_argument('hash', None)
    obj = self.get_argument('obj', None)
    parent = self.get_argument('parent', None)
    if (not coll) or (not hsh) or (not obj): raise HTTPError(500, 'coll, hash, obj not provided')

    obj = json.loads(obj)

    oldid = obj['id']
    newid = self.orm.append(coll, obj, parent)

    return { 'hash': hsh, 'coll': coll, 'oldid': oldid, 'newid': newid }

  # TODO(dem) search relations
  def opDelete(self):
    coll = self.get_argument('coll', None)
    objid = self.get_argument('id', None)
    parent = self.get_argument('parent', None)
    if (not coll) or (not objid): raise HTTPError(500, 'coll, id not found')

    self.orm.delete(coll, objid, parent)

    return { 'coll': coll, 'id': objid }

  # TODO(dem) implement this
  def opUpdate(self):
    coll = self.get_argument('coll', None)
    objid = self.get_argument('id', None)
    values = self.get_argument('values', None)
    parent = self.get_argument('parent', None)

    if (not coll) or (not objid) or (not values): raise HTTPError(500)

    obj = json.loads(obj)

    return {}

  def opSelectOne(self):
    coll = self.get_argument('coll', None)
    hsh = self.get_argument('hash', None)
    slug = self.get_argument('slug', None)
    if (not coll) or (not hsh) or (not slug):
      raise HTTPError(500, 'provide coll, hash, slug')

    obj = self.orm.selectOne(coll, {'slug': slug})

    return {'hash': hsh, 'obj': obj}

  def opSelectFrom(self):
    coll = self.get_argument('coll', None)
    hsh = self.get_argument('hash', None)
    parent = self.get_argument('parent', None)
    if (not coll) or (not hsh):
      raise HTTPError(500)

    items = self.orm.selectFrom(coll, {}, parent)

    return {'hash': hsh, 'coll': items}

  def get(self, appName):
    if not self.isXhr(): raise HTTPError(401)

    self.writeJson({})

  # @authenticated
  # TODO(dem) check operation right
  def post(self):
    if not self.isXhr():
      raise HTTPError(403)

    # get operation
    op = self.get_argument('op', None)
    if not op: raise HTTPError(500)

    ops = {
      'value': self.opValue,
      'insert': self.opInsert,
      'insert_before': self.opInsertBefore,
      'insert_after': self.opInsertAfter,
      'append': self.opAppend,
      'delete': self.opDelete,
      'update': self.opUpdate,
      'select_one': self.opSelectOne,
      'select_from': self.opSelectFrom,
    }

    fn = ops.get(op, None)
    if not fn:
      raise HTTPError(500, 'unknown op: ' + str(op))

    response = fn();

    self.writeJson(response)

class OrmImageHandler(BaseHandler):

  @authenticated
  def post(self):
    print 'OrmImageHandler'
    # if 'op' in self.request
    self.writeJson({})

class NotFoundHandler(BaseHandler):

  def get(self):
    self.render('404.html')

class NoscriptHandler(BaseHandler):

  def get(self):
    self.render('noscript.html')

urls = [
    ('/op', OrmOpHandler),
    ('/op-image', OrmImageHandler),
    ('/noscript', NoscriptHandler),
  ]

