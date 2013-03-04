import hashlib
import random
import base64
import uuid

def encodeSaltPassword(salt, rawPassword):
  return hashlib.sha1(salt + rawPassword).hexdigest()

def generateSalt():
  return encodeSaltPassword(str(random.random()), str(random.random()))[:7]

def encodePassword(rawPassword):
  salt = generateSalt()
  hsh = encodeSaltPassword(salt, rawPassword)
  return '%s$%s' % (salt, hsh)

def checkPassword(rawPassword, encPassword):
  salt, password = encPassword.split('$')
  testPassword = encodeSaltPassword(salt, rawPassword)
  return password == testPassword

def genPassword():
  return base64.b64encode(uuid.uuid4().bytes + uuid.uuid4().bytes)

