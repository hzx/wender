

# create library instances
ns.init = ->
  initEvents()
  initAnimation()
  initNet()
  ns.router = new ns.Router()
  ns.browser = new ns.Browser()
  ns.net = new ns.Net()
  ns.validator = new ns.Validator()
  ns.orm = new ns.Orm()

