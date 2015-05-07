

ns.canvasSupportFlag = false

canvasSupport = ->
  canvas = null
  try
    canvas = document.createElement("canvas")
  catch e
    return false
  return !!canvas && !!canvas.getContext


requestAnimationFrame = null
cancelAnimationFrame = null

isRenderRun = false
lastTime = null

animatorRender = ->
  if isRenderRun
    requestAnimationFrame(animatorRender)


initAnimation = ->
  lastTime = 0
  id = null
  vendors = ['ms', 'moz', 'webkit', 'o']
  for vendor in vendors
    requestAnimationFrame = window[vendor + 'RequestAnimationFrame']
    cancelAnimationFrame = window[vendor + 'CancelAnimationFrame'] ||
      window[vendor + 'CancelRequestAnimationFrame']
    if !!requestAnimationFrame
      break

  # TODO: remove fucking coffeescript - stupid language, how to change value?!
  # not create it!!!
  # if !ns.requestAnimationFrame
  #   ns.requestAnimationFrame = (callback) ->
  #     currTime = new Date().getTime()
  #     timeToCall = Math.max(0, 16 - (currTime - lastTime))
  #     id = window.setTimeout(() -> callback(currTime + timeToCall), timeToCall)
  #     lastTime = currTime + timeToCall
  #     return id

  # if !ns.cancelAnimationFrame
  #   ns.cancelAnimationFrame = (id) -> clearTimeout(id)

  ns.canvasSupportFlag = canvasSupport()
