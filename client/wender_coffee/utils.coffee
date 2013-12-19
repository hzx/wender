

class ns.HashGenerator
  constructor: ->
    @hashCounter = 0

  generate: ->
    @hashCounter = @hashCounter + 1
    return (new Date()).getTime().toString() + '-' + @hashCounter


hashCounter = 1
lastTime = null
ns.generateHash = () ->
  now = (new Date()).getTime()
  hashCounter = if now is lastTime then hashCounter + 1 else 1
  lastTime = now
  return now.toString() + '-' + hashCounter.toString()


encodeDict = (dict) ->
  isFirst = true
  result = ""
  for key, value of dict
    if isFirst then isFirst = false else result = result + "&"
    result = result + key + "=" + encodeURIComponent(value)
  result


extendSingleton = (cl) ->
  cl.instance_ = null
  cl.getInstance = ->
    if cl.instance_ is null
      cl.instance_ = new cl()
    return cl.instance_
ns.extendSingleton = extendSingleton


trimString = (text) ->
  return text.toString().replace(/^\s+|\s+$/g, '')
ns.trimString = trimString

tagsRe = /[a-zA-Z0-9а-яА-Я]+/g
pretextsRaw = ['в', 'без', 'до', 'из', 'к', 'на', 'по', 'о', 'от', 'перед', 'при', 'через', 'с', 'у', 'за', 'над', 'об', 'под', 'про', 'для']
pretexts = {}
for it in pretextsRaw
  pretexts[it] = null
extractTags = (text, isFilter = false) ->
  words = text.match(tagsRe)
  filtered = []
  if words is null
    return filtered
  for word in words
    if (word.length <= 1) or (isFilter and (word of pretexts))
      continue
    filtered.push(word.toLowerCase())
  return filtered
ns.extractTags = extractTags

createPartialTags = (tags) ->
  buf = {}
  tag = null
  word = null
  for tag in tags
    buf[tag] = null
    if tag.length <= 2
      continue
    for num in [1..tag.length-1]
      word = tag.substr(0, num+1)
      buf[word] = null
  res = []
  for tag of buf
    res.push(tag)
  return res
ns.createPartialTags = createPartialTags

ns.extractAllTags = (text) ->
  return createPartialTags(extractTags(text, true))

ns.setMapValue = (map, key, value) ->
  map[key] = value

ns.arrayInAnd = (field, arr) ->
  fields = []
  piece = null
  for item in arr
    val = {}
    val[field] = item
    fields.push(val)
  return fields

arrayEquals = (a, b) ->
  if a is b
    return true
  if ((a is null) or (a.length is 0)) and ((b is null) or (b.length is 0))
    return true
  if (a is null) or (b is null)
    return false
  if a.length isnt b.length
    return false
  for av, i in a
    if av isnt b[i]
      return false
  return true
ns.arrayEquals = arrayEquals

ns.newDateString = ->
  created = new Date()
  return created.toString()

ns.parseInt = (val) ->
  n = parseInt(val, 10)
  if isNaN(n)
    return 0
  else
    return n


getSourceArrayString = (arr, field) ->
  buf = []
  for item in arr
    buf.push('"' + item[field] + '"')
  return '[' + buf.join(', ') + ']'


class Comparator
  constructor: (field, order) ->
    @field = field
    if order is 'asc'
      @compare = @compareAsc
    else if order is 'desc'
      @compare = @compareDesc
    else
      throw new Error('sort order not known: "' + order + '"')

  compareAsc: (left, right) ->
    return left[@field] <= right[@field]

  compareDesc: (left, right) ->
    return left[@field] >= right[@field]


qsortPartition = (arr, left, right, pivot, comparator) ->
  pivotValue = arr[pivot]
  arr[pivot] = arr[right]
  arr[right] = pivotValue
  storeIndex = left
  value = null
  for i in [left..(right-1)]
    if comparator.compare(arr[i], pivotValue)
      value = arr[i]
      arr[i] = arr[storeIndex]
      arr[storeIndex] = value
      storeIndex = storeIndex + 1
  value = arr[storeIndex]
  arr[storeIndex] = arr[right]
  arr[right] = value
  return storeIndex

ns.qsort = qsort = (arr, left, right, comparator) ->
  if left < right
    pivot = Math.floor((left + right) / 2)
    pivotNew = qsortPartition(arr, left, right, pivot, comparator)
    qsort(arr, left, pivotNew - 1, comparator)
    qsort(arr, pivotNew + 1, right, comparator)
