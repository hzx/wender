

describe "Dom tests", ->

  beforeEach ->
    window.wender.init()

  afterEach ->
    # page = wender.browser.getElementById('page')
    # if page isnt null
    #   wender.browser.removeElement(page)

  it "create element", ->
    w = window.wender

    title = new w.ObservableValue()

    page = new w.DomElement('div', {'id': 'page'}, [
      new w.DomText [title], (values) ->
        values[0].value
    ], null, null)

    w.browser.appendElement(page)

    title.setValue('Hello, World!')

  it "create text", ->
    w = window.wender

  it "create element childs", ->
    w = window.wender

    copyright = new w.ObservableValue()

    page = new w.DomElement('div', {'id': 'page'}, [
      new w.DomElement('div', {'id': 'header'}, [], null, null),
      new w.DomElement('div', {'id': 'content'}, [], null, null),
      new w.DomElement('div', {'id': 'footer'}, [
        new w.DomText [copyright], (values) ->
          values[0].value
      ], null, null)
    ], null, null)

    w.browser.appendElement(page)

    copyright.setValue('copyright 2013 rubear')

