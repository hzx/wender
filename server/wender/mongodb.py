from wender.db import storable
from bson.objectid import ObjectId


@storable
def insert(db, collName, values):
  if not ('id' in values):
    newid = ObjectId()
    values['id'] = newid
  else:
    newid = values['id']
  db[collName].insert(values)
  return str(newid)

@storable
def selectOne(db, collName, where=None):
  if where:
    return db[collName].find_one(where)
  
  return db[collName].find_one()

@storable
def selectFrom(db, collName, where=None):
  if where:
    return db[collName].find(where)

  return db[collName].find()

@storable
def update(db, collName, values, where=None):
  if where:
    return db[collName].update(where, { '$set': values })

  return db[collName].update({}, { '$set': values }, upsert=True, multi=True)

@storable
def delete(db, collName, where=None):
  if where:
    return db[collName].remove(where)

  return db[collName].remove()

