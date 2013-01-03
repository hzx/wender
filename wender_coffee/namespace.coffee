
ns = window.wender = {}
ns.initTasks = []
ns.init = ->
  for task in ns.initTasks
    task()
