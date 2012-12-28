

ns.addEventHandler = if document.body.addEventListener
  (target, eventType, handler) ->
    target.addEventListener(eventType, handler, false)
else
  (target, eventType, handler) ->
    target.attachEvent("on" + eventType, handler)

ns.removeEventHandler = if document.body.removeEventListener
  (target, eventType, handler) ->
    target.removeEventListener(eventType, handler, false)
else
  (target, eventType, handler) ->
    target.detachEvent("on" + eventType, handler)
