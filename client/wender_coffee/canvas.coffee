
canvasSupport = ->
  canvas = null
  try
    canvas = document.createElement('canvas')
  catch e
    return false
  return !!canvas or !!canvas.getContext
