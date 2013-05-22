from wender.db import storable, getId


@storable
def createIndex(db, coll, indexName):
    db[coll].create_index(indexName)


@storable
def insert(db, coll, obj):
    # set new id
    newid = getId()
    obj['id'] = newid

    db[coll].insert(obj)

    return newid


@storable
def selectOne(db, coll, where=None):
    if where:
        return db[coll].find_one(where)

    return db[coll].find_one()


@storable
def selectFrom(db, coll, where=None):
    if where:
        return db[coll].find(where)

    return db[coll].find()


@storable
def update(db, coll, values, where=None):
    if where:
        return db[coll].update(where, {'$set': values})

    return db[coll].update({}, {'$set': values}, upsert=False, multi=True)


@storable
def delete(db, coll, where=None):
    if where:
        return db[coll].remove(where)

    return db[coll].remove()
