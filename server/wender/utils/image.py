import tornado
from tornado.options import options
import os.path
import hashlib
import random
import Image


# public method
def saveOneRequestFile(requestFile, path):
  filename = requestFile['filename']
  randomFilename = generateFilename(filename)
  randomFilePath = os.path.join(path, randomFilename)

  fileBody = requestFile['body']
  outputFile = open(randomFilePath, 'w')
  outputFile.write(fileBody)
  outputFile.close()

  return randomFilename


# public method
def saveMultiRequestFile(requestFiles, path):
  files = []
  for item in requestFiles:
    filename = saveOneRequestFile(item, path)
    files.append(filename)
  return files


# internal method
def generateFilename(original):
  name, ext = os.path.splitext(original)
  return  hashlib.md5(str(random.random()) + str(random.random())).hexdigest() + ext


# internal method
def addFilenameSuffix(filename, suffix):
  """
  Add suffix to filename before extension
  """
  name, ext = os.path.splitext(filename)
  return name + suffix + ext


# internal method
def calcImageSize(boundSize, image):
  """
  Calculate size(width, height) relative bound size for image with
  saved aspect ration.

  Return (width, height).
  """
  imageWidth = image.size[0]
  imageHeight = image.size[1]

  # width / height
  aspect = float(imageWidth) / float(imageHeight)

  widthDiv = float(imageWidth) / float(boundSize[0])
  heightDiv = float(imageHeight) / float(boundSize[1])

  # base metrics is width
  if widthDiv > heightDiv:
    # width = bound.width
    width = boundSize[0]
    # height = width / aspect
    height = int(float(width) / float(aspect))
  # base metrics is height
  else:
    # height = bound.height
    height = boundSize[1]
    # width = height * aspect
    width = int(float(height) * float(aspect))

  return (width, height)


# public method
def createResizedImage(srcFilename, destFilename, size):
  """
  Create resized destFilename image from srcFilename with bound in size.
  Save resized image to destFilename.

  srcFilename, destFilename must be absolute path.
  """
  image = Image.open(srcFilename)
  if image.mode not in ('L', 'RGB'):
    image = image.convert('RGB')

  image = image.resize(calcImageSize(size, image), Image.ANTIALIAS)

  image.save(destFilename, image.format)


# public method
def createResizedImages(filename, path, sizes):
  filenameAbs = os.path.join(path, filename)
  for size in sizes:
    dest = os.path.join(path, '%dx%d' % size, filename)
    createResizedImage(filenameAbs, dest, size)


# public method
def deleteImage(filename, path, sizes):
  if len(filename) == 0:
    return
  filenameAbs = os.path.join(path, filename)
  if os.path.exists(filenameAbs):
    os.remove(filenameAbs)
  for size in sizes:
    sized = os.path.join(path, '%dx%d' % size, filename)
    if os.path.exists(sized):
      os.remove(sized)
