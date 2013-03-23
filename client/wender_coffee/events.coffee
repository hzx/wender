

initEvents = ->
  ns.addEvent = if document.body.addEventListener
    ns.isIe = false
    (target, eventType, handler) ->
      target.addEventListener(eventType, handler, false)
  else
    ns.isIe = true
    (target, eventType, handler) ->
      target.attachEvent("on" + eventType, handler)

  ns.removeEvent = if document.body.removeEventListener
    (target, eventType, handler) ->
      target.removeEventListener(eventType, handler, false)
  else
    (target, eventType, handler) ->
      target.detachEvent("on" + eventType, handler)

  ns.stopPropagation = if ns.isIe
    (event) ->
      event.cancelBubble = true
  else
    (event) ->
      event.stopPropagation()

  ns.preventDefault = if ns.isIe
    (event) ->
      event.returnValue = false
      return false
  else
    (event) ->
      event.preventDefault()

  ns.setText = if ns.isIe
    (node, text) ->
      # node.innerText = text
      node.nodeValue = text
  else
    (node, text) ->
      node.textContent = text

