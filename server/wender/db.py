import tornado
import tornado.options
from tornado.options import options
import tornado.web

import pymongo
from pymongo.mongo_client import MongoClient
from bson.objectid import ObjectId
import pymongo.errors
import bson.json_util
import json
from datetime import datetime

import functools



RECONNECT_COUNT = 3
db = None


def connect():
  # connection = pymongo.Connection(options.db_host)
  # db = connection[options.db_name]
  # db.authenticate(options.db_user, options.db_password)
  connection = MongoClient()
  db = connection[options.db_name]
  return db

def authorize(db):
  # db.authenticate(options.db_user, options.db_password)
  pass


# database methods decorator
def storable(method):
  @functools.wraps(method)
  def wrapper(*args, **kwargs):
    global db

    result = None
    for i in range(RECONNECT_COUNT):
      try:
        if db == None: db = connect()
        else: authorize(db)
        result = method(db, *args, **kwargs)
        # if method called ok then break cicle
        break
      except pymongo.errors.AutoReconnect, error:
        print 'Warning', error
        db = None
        #time.sleep(5)
      except pymongo.errors.DuplicateKeyError:
        # It worked first time
        pass
      except pymongo.errors.PyMongoError, error:
        print 'Error', error
        raise tornado.web.HTTPError(500, str(error))

    return result
  return wrapper


def jsonDefault(obj):
  """
  serialize ObjectId to string instead of map {"$oid": str}
  """
  # override default serialization
  if isinstance(obj, ObjectId):
    return str(obj)
  if isinstance(obj, datetime):
    return obj.strftime("%Y-%m-%d %H:%M:%S")
  # call default serialization
  return pymongo.json_util.default(obj)


def listToJson(cursor):
  result = '['
  prefixComma = False
  for item in cursor:
    jsonAlbum = json.dumps(item, default=jsonDefault)
    if prefixComma:
      result += ','
    else:
      prefixComma = True
    result += jsonAlbum
  result += ']'

  # TODO(dem) check it
  # return json.dumps(list(cursor), default=jsonDefault)

  return result

def cursorToList(cursor):
  return [item for item in cursor]


def toJson(item):
  #return json.dumps(item, default=pymongo.json_util.default)
  return json.dumps(item, default=jsonDefault)

  
