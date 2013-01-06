

class TestUser
  constructor: ->
    @id = null
    @name = new window.wender.ObservableValue()

  getHash: ->
    @id

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
        new w.DomText '', [copyright], (values) ->
          values[0].value
      ], null, null)
    ], null, null)

    w.browser.appendElement(page)

    copyright.setValue('copyright 2013 rubear')

    pageElement = w.browser.body.first
    expect(pageElement).not.toEqual(null)
    expect(pageElement.id).toEqual('page')

    headerElement = pageElement.first
    expect(headerElement).not.toEqual(null)
    expect(headerElement.id).toEqual('header')
    expect(headerElement.hash).not.toEqual(null)
    
    contentElement = pageElement.first.next
    expect(contentElement).not.toEqual(null)
    expect(contentElement.id).toEqual('content')
    expect(contentElement.hash).not.toEqual(null)
    expect(contentElement.hasClass('common-content')).toEqual(true)
    expect(contentElement.hasClass('rounded-box')).toEqual(true)

    footerElement = pageElement.last
    expect(footerElement).not.toEqual(null)
    expect(footerElement.id).toEqual('footer')
    expect(footerElement.hash).not.toEqual(null)

    copyrightText = footerElement.first
    expect(copyrightText).not.toEqual(null)
    expect(copyrightText.text).toEqual('copyright 2013 rubear')

  it "listen observable list", ->
    w = window.wender

    list = new w.ObservableList()
    u1 = new TestUser()
    u1.id = '1'
    u1.name.setValue('mercedes')
    u2 = new TestUser()
    u2.id = '2'
    u3 = new TestUser()
    u3.id = '3'
    u3.name.setValue('lamborgini')

    list.append(u1)
    list.append(u3)

    list.addInsertListener (obj, before) ->

    page = new w.DomElement 'div', {'id': 'page'}, [], list, (item) ->
      new wender.DomElement 'div', {'class': ['auto']}, [
        new wender.DomText '', [item.name], (values) ->
          values[0].value
      ], null, null

    w.browser.appendElement(page)

    list.append(u2)
    u2.name.setValue('bmw')

    mercedes = page.first
    expect(mercedes).not.toEqual(null)
    expect(mercedes.first.text).toEqual('mercedes')

    lamborgini = mercedes.next
    expect(lamborgini).not.toEqual(null)
    expect(lamborgini.first.text).toEqual('lamborgini')

    bmw = lamborgini.next
    expect(bmw).not.toEqual(null)
    expect(bmw.first.text).toEqual('bmw')

    u2.name.setValue('new bmw')
    expect(bmw.first.text).toEqual('new bmw')

    page.empty()

    expect(page.first).toEqual(null)

  it "event test", ->
    page = new wender.DomElement 'div', {'id': 'page', 'onclick': (e) =>
      console.log e
      e.element.append(new wender.DomElement 'div', {'class': ['message']}, [
        new wender.DomText('you clicked me', null, null)
      ], null, null)
    }, [
      new wender.DomText 'CLICK ME', null, null
    ], null, null

    wender.browser.appendElement(page)
