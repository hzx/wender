

describe "Dom tests", ->

  beforeEach ->
    window.wender.init()

  afterEach ->
    # page = wender.browser.getElementById('page')
    # if page isnt null
    #   wender.browser.removeElement(page)

  it "create element childs", ->
    w = window.wender

    copyright = new w.ObservableValue()

    page = new w.DomElement('div', {'id': 'page'}, [
      new w.DomElement('div', {'id': 'header'}, [], null, null),
      new w.DomElement('div', {'id': 'content', 'class': ['common-content', 'rounded-box']}, [], null, null),
      new w.DomElement('div', {'id': 'footer'}, [
        new w.DomText [copyright], (values) ->
          values[0].value
      ], null, null)
    ], null, null)

    w.browser.appendElement(page)

    copyright.setValue('copyright 2013 rubear')

    expect(w.browser.body.childs.count).toEqual(1)
    pageElement = w.browser.body.childs.first.obj
    expect(pageElement).not.toEqual(null)
    expect(pageElement.id).toEqual('page')
    expect(pageElement.childs.count).toEqual(3)

    headerElement = pageElement.childs.first.obj
    expect(headerElement).not.toEqual(null)
    expect(headerElement.id).toEqual('header')
    expect(headerElement.childs.count).toEqual(0)
    expect(headerElement.hash).not.toEqual(null)
    
    contentElement = pageElement.childs.first.next.obj
    expect(contentElement).not.toEqual(null)
    expect(contentElement.id).toEqual('content')
    expect(contentElement.childs.count).toEqual(0)
    expect(contentElement.hash).not.toEqual(null)
    expect(contentElement.hasClass('common-content')).toEqual(true)
    expect(contentElement.hasClass('rounded-box')).toEqual(true)

    footerElement = pageElement.childs.last.obj
    expect(footerElement).not.toEqual(null)
    expect(footerElement.id).toEqual('footer')
    expect(footerElement.childs.count).toEqual(1)
    expect(footerElement.hash).not.toEqual(null)

    copyrightText = footerElement.childs.first.obj
    expect(copyrightText).not.toEqual(null)
    expect(copyrightText.text).toEqual('copyright 2013 rubear')
