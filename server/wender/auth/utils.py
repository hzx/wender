
from arti.auth import models


def getCurrentUser(requestHandler):
  userId = requestHandler.get_secure_cookie('user')
  if not userId: return None
  return models.getUser(userId)


