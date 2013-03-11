from wender.db import storable


@storable
def insert(db, collName, values):
  db[collName].insert(values)

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

