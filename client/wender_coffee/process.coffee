

processArray = (items, process, callback) ->
  todo = items.concat() # create a clone of the original

  setTimeout(() ->
    start = +new Date()

    # do
    #   process(todo.shift())
    # while (todo.length > 0) and (+new Date() - start < 50)
    while true
      process(todo.shift())
      if (todo.length is 0) or (+new Date() - start >= 50)
        break

    if todo.length > 0
      setTimeout(arguments.callee, 25)
    else
      callback(items)
  , 25)

multistep = (steps, args, callback) ->
  tasks = steps.concat(); # clone the array

  setTimeout(() ->
    # execute the next task
    task = tasks.shift()
    task.apply(null, args || [])
    # determine if there's more
    if tasks.length > 0
      setTimeout(arguments.callee, 25)
    else
      callback()
  , 25)

