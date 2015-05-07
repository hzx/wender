import datetime

ISO_FORMAT = "%Y-%m-%d %H:%M:%S"

def datetimeToISOString(dt):
  return dt.strftime(ISO_FORMAT)


def datetimeFromISOString(st):
  return datetime.datetime.strptime(st, ISO_FORMAT)
