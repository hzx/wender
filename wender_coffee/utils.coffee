

ns.loadScript = (url, callback) ->
  script = document.createElement("script")
  script.type = "text/javascript"

  if script.readyState
    script.onreadystatechange = () ->
      if script.readyState == "loaded" or script.readyState == "complete"
        script.onreadystatechange = null
        callback()
  else
    script.onload = () ->
      callback()

  script.src = url
  document.getElementsByTagName("head")[0].appendChild(script)

ns.loadCss = (url) ->
  link = document.createElement('link')
  link.type = "text/css"
  link.rel = "stylesheet"
  link.href = url
  document.getElementsByTagName("head")[0].appendChild(link)

