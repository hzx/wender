from datetime import datetime
from bson.objectid import ObjectId
import bson.json_util
import json


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
  return bson.json_util.default(obj)


def toJson(item):
  #return json.dumps(item, default=pymongo.json_util.default)
  return json.dumps(item, default=jsonDefault)
