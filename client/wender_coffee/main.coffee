

# create library instances
ns.init = ->
  initEvents()
  initAnimation()
  initNet()
  window.browser = ns.browser = new ns.Browser()
  ns.net = new ns.Net()
  ns.orm = new ns.Orm()

