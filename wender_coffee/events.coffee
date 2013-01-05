
ns.initTasks.push ->
  ns.addEvent = if document.body.addEventListener
    ns.isIe = false
    (target, eventType, handler) ->
      target.addEventListener(eventType, handler, false)
  else
    ns.isIe = true
    (target, eventType, handler) ->
      # target.attachEvent("on" + eventType, handler)
      target.attachEvent(eventType, handler)

  ns.removeEvent = if document.body.removeEventListener
    (target, eventType, handler) ->
      target.removeEventListener(eventType, handler, false)
  else
    (target, eventType, handler) ->
      # target.detachEvent("on" + eventType, handler)
      target.detachEvent(eventType, handler)
