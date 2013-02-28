
import pymongo
from uilit.utils.crypt import encode_password, check_password

class Auth(object):
  def __init__(self, application):
    self.application = application

  @property
  def db(self):
    return self.application.db

  def get_user(self, login):
    user = self.db.user.find_one({ 'login': login })
    return user

  def reg_user(self, login, password):
    enc_password = encode_password(password)

    self.db.user.insert({ 'login': login, 'password': enc_password })

  def get_user_by_id(self, id):
    user = self.db.user.find_one({ '_id': id })
    return user

