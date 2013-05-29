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
  return hashlib.md5(str(random.random())
                     + str(random.random())).hexdigest() + ext


# internal method
def addFilenameSuffix(filename, suffix):
  """
  Add suffix to filename before extension
  """
  name, ext = os.path.splitext(filename)
  return name + suffix + ext


# internal method
def calcImageSize(size, image):
  """
  Calculate size(width, height) relative bound size for image with
  saved aspect ratio.

  Return (width, height).
  """
  iw = image.size[0]
  ih = image.size[1]

  # don't resize small images to bigger
  if (iw < size[0]) or (ih < size[1]):
    return (iw, ih)

  # width / height
  ratio = float(iw) / float(ih)

  wmul = float(iw) / float(size[0])
  hmul = float(ih) / float(size[1])

  # base metrics is width
  if wmul > hmul:
    # width = bound.width
    width = size[0]
    # height = width / aspect
    height = int(float(width) / float(ratio))
  # base metrics is height
  else:
    # height = bound.height
    height = size[1]
    # width = height * aspect
    width = int(float(height) * float(ratio))

  return (width, height)


def calcImageCropSize(size, image):
  """
  Calculate size(width, height) outbound size
  """
  iw = image.size[0]
  ih = image.size[1]

  # width / height
  ratio = float(iw) / float(ih)
  # destratio = float(size[0]) / float(size[1])

  wmul = float(iw) / float(size[0])
  hmul = float(ih) / float(size[1])

  if wmul > hmul:
    height = size[1]
    width = int(float(height) * float(ratio))
  else:
    width = size[0]
    height = int(float(width) / float(ratio))

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


def createResizedImageCrop(src, dest, size):
  image = Image.open(src)
  if image.mode not in ('L', 'RGB'):
    image = image.convert('RGB')

  preCropSize = calcImageCropSize(size, image)

  image = image.resize(preCropSize, Image.ANTIALIAS)
  # compute crop size
  if preCropSize[0] > size[0]:
    left = int(float(preCropSize[0] - size[0]) / 2.0)
  else:
    left = 0
  if preCropSize[1] > size[1]:
    top = int(float(preCropSize[1] - size[1]) / 2.0)
  else:
    top = 0
  right = left + size[0]
  bottom = top + size[1]
  # crop image to size
  image = image.crop((left, top, right, bottom))
  image.save(dest, image.format)


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
