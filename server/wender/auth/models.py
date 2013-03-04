import tornado.web
import pymongo
from bson.objectid import ObjectId
from wender.db import storable
from wender.utils import crypt


@storable
def createUser(db, login, password):
  user = { 'login': login, 'password': crypt.encodePassword(password) }
  userId = db.user.insert(user)
  user['_id'] = str(userId)
  return user


@storable
def getUser(db, userId):
  return db.user.find_one({ '_id': ObjectId(userId) })


@storable
def getUserByLogin(db, login):
  return db.user.find_one({ 'login': login })


@storable
def checkUserPassword(db, user, password):
  # check if user exist
  if user == None: return False

  return crypt.checkPassword(password, user['password'])
