

describe "ObservableList tests", ->

  beforeEach ->
    @list = new wender.ObservableList([])

  afterEach ->

  it "check append", ->
    isAppended = false

    @list.addInsertListener (obj, before) ->
      isAppended = true

    o1 = new HashObject('value01')
    o1.hash = 'hash01'

    @list.append(o1)

    expect(isAppended).toEqual(true)

  it "check delete", ->
    isDeleted = false

    @list.addDeleteListener (obj) ->
      isDeleted = true

    o1 = new HashObject('value01')
    o1.hash = 'hash01'

    o2 = new HashObject('value02')
    o2.hash = 'hash02'

    @list.append(o1)
    @list.append(o2)
    @list.remove(o2.getHash())

    expect(isDeleted).toEqual(true)
