import os
import base64
import uuid

import subprocess
import sys


def execute(*command):
  exitcode = subprocess.call(command)
  if exitcode != 0:
    sys.exit(exitcode)


# TODO(dem) check CalledProcessError and make sys.exit with code
def executeWithOutput(*command):
  output = subprocess.check_output(command)
  return output


def executeWithOutputShell(command):
  output = subprocess.check_output(command, shell=True)
  return output


def spamCheck(msg):
  # save tmp file
  filename = os.path.join('/tmp', str(uuid.uuid4()))
  with open(filename, 'w') as f: f.write(msg)

  res = executeWithOutputShell('spamc -R < ' + filename)

  # delete tmp file
  os.remove(filename)

  return res
