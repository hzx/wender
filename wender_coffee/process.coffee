
ns.chunk = (array, process, context) ->
  setTimeout ->
    item = array.shift()
    process.call context, item
    if array.length > 0 then setTimeout arguments.callee, 100
  , 100
