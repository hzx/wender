import tornado.web
import hashlib
import pymongo
from uilit.site.handlers import BaseHandler
from uilit.utils.crypt import check_password


class CaptchaHandler(BaseHandler):
  def get(self, user_key):
    # TODO: by user_key generate captcha
    pass


class RegHandler(BaseHandler):
  def get(self):
    self.render("reg.html", captcha=self.captcha.create())
    
  def post(self):
    # fetch login and password
    login = self.get_argument('login', '')
    password = self.get_argument('password', '')
    captcha = self.get_argument('captcha', '')

    # validate login, password, captcha
    if not self.captcha.check(captcha):
      self.write('captcha wrong')
      return

    # get record from database for current login
    user = self.auth.get_user(login)

    # check login and password
    if user:
      self.write('user already exists')
      return

    self.auth.reg_user(login, password)
    self.write('user registration ok, login: %s' % login)



class LoginHandler(BaseHandler):

  '''
  def get(self):
    self.render('login.html', captcha=self.captcha.create())
  '''

  def get(self):
    self.write('login get method invoked')

  def post(self):
    # fetch login, password
    login = self.get_argument('login', None)
    password = self.get_argument('password', None)
    captcha = self.get_argument('captcha', '')

    # validate login, password, captcha
    if not self.captcha.check(captcha):
      self.write('captcha wrong')
      return


    # get user
    user = self.auth.get_user(login)

    # check login, password
    if user:
      if check_password(password, user['password']):
        self.set_secure_cookie('user', str(user.get('_id')))
        self.redirect('/')
      else:
        self.write('password error')
        return

    self.write('login not exists')



class LogoutHandler(BaseHandler):
  @tornado.web.authenticated
  def get(self):
    self.clear_cookie('user')
    self.redirect('/')


urls = [
  (r'/reg', RegHandler),
  (r'/login', LoginHandler),
  (r'/logout', LogoutHandler),
]
