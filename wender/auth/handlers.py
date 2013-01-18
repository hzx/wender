from tornado.web import HTTPError
from arti.site.handlers import BaseHandler
from arti.auth import models
#from arti.auth


class LoginHandler(BaseHandler):

  def redirectToAdmin(self):
    self.redirect('/admin')


  def get(self):
    # if already loginned then redirect to admin
    userId = self.get_secure_cookie('user')
    if userId != None:
      user = models.getUser(userId)
      if user != None: self.redirectToAdmin()

    self.set_cookie('_xsrf', self.xsrf_token, httponly=True)

    self.render('login_js.html', xsrf=self.xsrf_token)


  def post(self):
    login = self.get_argument('login')
    password = self.get_argument('password')

    # get saved user
    user = models.getUserByLogin(login)

    # check user
    if models.checkUserPassword(user, password):
      self.set_secure_cookie('user', str(user['_id']), httponly=True)
      self.writeJson({ 'user': 'ok' })
    else:
      # unauthorized
      raise HTTPError(401)


class LogoutHandler(BaseHandler):
  def get(self):
    self.clear_cookie('user')
    self.redirect('/login')


urls = [
  (r'/login', LoginHandler),
  (r'/logout', LogoutHandler),
]
