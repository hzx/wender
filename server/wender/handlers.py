from tornado.web import RequestHandler
from tornado.web import HTTPError
from tornado.web import authenticated
from wender.utils.mongodb import toJson


class BaseHandler(RequestHandler):

  @property
  def orm(self):
    return self.application.orm

  # may stop processing if calls finish or send_error
  # def prepare(self):
  #   pass

  # render error pages
  def write_error(self, status_code, **kwargs):
    print 'status_code "%d"' % status_code
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

  def initialize(self, appName):
    self.appName = appName

  def get(self):
    if not self.isXhr():
      raise HTTPError(401)

    # load orm data
    self.writeJson({'xsrf': self.xsrf_token })

class OrmOpHandler(BaseHandler):

  def get(self, appName):
    if not self.isXhr():
      raise HTTPError(401)

    self.writeJson({})

class NotFoundHandler(BaseHandler):

  def get(self):
    self.render('404.html')

class NoscriptHandler(BaseHandler):

  def get(self):
    self.render('noscript.html')

urls = [
    ('/load', OrmLoadHandler, {'appName': 'test'}),
    ('/op', OrmOpHandler),
    ('/noscript', NoscriptHandler),
  ]

