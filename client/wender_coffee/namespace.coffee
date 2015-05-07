
ns = window.wender = {}


Debugger = {}

Debugger.log = (message) ->
  try
    console.log(message)
  catch exception
    return

ns.Debugger = Debugger

ns.log = (message) ->
  Debugger.log(message)


# ns.strftime = (format) ->
