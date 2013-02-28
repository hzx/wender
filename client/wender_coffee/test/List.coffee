
class HashObject
  constructor: (value) ->
    @value = value
    @hash = null

  getHash: ->
    @hash

describe "List tests", ->

  beforeEach ->
    @list = new wender.List()

  afterEach ->

  it "check insert", ->
    o1 = new HashObject('ov1')
    o1.hash = '1'
    o2 = new HashObject('ov2')
    o2.hash = '2'
    o3 = new HashObject('ov3')
    o3.hash = '3'

    @list.insert(o1)

    expect(@list.first.prev).toEqual(null)
    expect(@list.last.next).toEqual(null)
    expect(@list.first.obj).toEqual(o1)
    expect(@list.last.obj).toEqual(o1)

    @list.insert(o2)

    expect(@list.first.prev).toEqual(null)
    expect(@list.last.next).toEqual(null)
    expect(@list.first.obj).toEqual(o2)
    expect(@list.last.obj).toEqual(o1)
    expect(@list.first.obj).toEqual(o2)
    expect(@list.last.obj).toEqual(o1)

    @list.insert(o3)

    expect(@list.first.prev).toEqual(null)
    expect(@list.last.next).toEqual(null)
    expect(@list.first.obj).toEqual(o3)
    expect(@list.last.obj).toEqual(o1)
    expect(@list.first.next.obj).toEqual(o2)
    expect(@list.last.prev.obj).toEqual(o2)

  it "check insert before", ->
    o1 = new HashObject('ov1')
    o1.hash = '1'
    o2 = new HashObject('ov2')
    o2.hash = '2'
    o3 = new HashObject('ov3')
    o3.hash = '3'

    @list.insert(o1)
    @list.insertBefore(o2, o1)

    # o2 o1

    expect(@list.first.prev).toEqual(null)
    expect(@list.last.next).toEqual(null)
    expect(@list.first.obj).toEqual(o2)
    expect(@list.last.obj).toEqual(o1)
    expect(@list.first.next.obj).toEqual(o1)
    expect(@list.last.prev.obj).toEqual(o2)

    @list.insertBefore(o3, o1)

    # o2 o3 o1

    expect(@list.first.prev).toEqual(null)
    expect(@list.last.next).toEqual(null)
    expect(@list.first.obj).toEqual(o2)
    expect(@list.last.obj).toEqual(o1)
    expect(@list.first.next.obj).toEqual(o3)
    expect(@list.last.prev.obj).toEqual(o3)
    expect(@list.first.next.prev.obj).toEqual(o2)
    expect(@list.last.prev.next.obj).toEqual(o1)

  it "check insert after", ->
    o1 = new HashObject('ov1')
    o1.hash = '1'
    o2 = new HashObject('ov2')
    o2.hash = '2'
    o3 = new HashObject('ov3')
    o3.hash = '3'

    @list.append(o1)
    @list.insertAfter(o2, o1)

    # o1 o2

    expect(@list.first.prev).toEqual(null)
    expect(@list.last.next).toEqual(null)
    expect(@list.first.obj).toEqual(o1)
    expect(@list.last.obj).toEqual(o2)
    expect(@list.first.next.obj).toEqual(o2)
    expect(@list.last.prev.obj).toEqual(o1)
    expect(@list.first.next).toEqual(@list.last)
    expect(@list.last.prev).toEqual(@list.first)

  it "check append", ->
    o1 = new HashObject('ov1')
    o1.hash = '1'
    o2 = new HashObject('ov2')
    o2.hash = '2'
    o3 = new HashObject('ov3')
    o3.hash = '3'

    @list.append(o1)

    expect(@list.first.prev).toEqual(null)
    expect(@list.last.next).toEqual(null)
    expect(@list.first.obj).toEqual(o1)
    expect(@list.last.obj).toEqual(o1)

    @list.append(o2)

    expect(@list.first.prev).toEqual(null)
    expect(@list.last.next).toEqual(null)
    expect(@list.first.obj).toEqual(o1)
    expect(@list.last.obj).toEqual(o2)
    expect(@list.first.obj).toEqual(o1)
    expect(@list.last.obj).toEqual(o2)

    @list.append(o3)

    expect(@list.first.prev).toEqual(null)
    expect(@list.last.next).toEqual(null)
    expect(@list.first.obj).toEqual(o1)
    expect(@list.last.obj).toEqual(o3)
    expect(@list.first.next.obj).toEqual(o2)
    expect(@list.last.prev.obj).toEqual(o2)

  it "check remove", ->
    o1 = new HashObject('ov1')
    o1.hash = '1'
    o2 = new HashObject('ov2')
    o2.hash = '2'
    o3 = new HashObject('ov3')
    o3.hash = '3'

    @list.append(o1)
    @list.append(o2)
    @list.append(o3)

    @list.remove(o1.getHash())

    expect(@list.first.prev).toEqual(null)
    expect(@list.last.next).toEqual(null)
    expect(@list.first.obj).toEqual(o2)
    expect(@list.last.obj).toEqual(o3)
    expect(@list.first.next).toEqual(@list.last)
    expect(@list.last.prev).toEqual(@list.first)

    @list.insert(o1)
    @list.remove(o2.getHash())
