from tornado.web import RequestHandler
from wender.utils.mongodb import toJson


class BaseHandler(RequestHandler):

  # may stop processing if calls finish or send_error
  def prepare(self):
    pass

  # render error pages
  def write_error(self):
    pass

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
  
  def on_connection_close(self):
    pass

  def set_default_headers(self):
    self.set_header('Server', 'wender')

  def isXhr(self):
    return self.request.headers.get('X-Requested-With', None) == 'XMLHttpRequest'

  def writeJson(self, obj):
    self.set_header('Content-Type', 'application/json;charset=UTF-8')
    self.finish(toJson(obj))


class LoginHandler(BaseHandler):
  def post(self):
    self.set_secure_cookie('user', self.get_argument('name'))



class NotFoundHandler(BaseHandler):
  def get(self):
    if self.isXhr():
      # return response for xhr request
      return
    self.render('404.html')
