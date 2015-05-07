
ns.mapCache = {}

ns.initializeMap = ->
  for key, map of ns.mapCache
    map.create()
  # reset cache
  ns.mapCache = {}

class ns.Map
  constructor: ->
    this.loaded = false
    this.id = ns.generateHash()
    this.srcNode = null
    this.map = null
    this.isCreate = false
    this.markers = []

  load: (node, lat, lng, zoom) ->
    this.node = node
    this.lat = lat
    this.lng = lng
    this.zoom = zoom
    this.loadScript()

  loadScript: ->
    if this.loaded
      return
    this.loaded = true

    s = document.createElement('script')
    s.type = 'text/javascript'
    s.src = 'https://maps.googleapis.com/maps/api/js?v=3.exp&sensor=false&' +
          'callback=wender.initializeMap'
    ns.mapCache[this.id] = this
    this.srcNode = s
    document.body.appendChild(s)

  create: ->
    options = {
      scrollwheel: false,
      zoom: this.zoom,
      center: new google.maps.LatLng(this.lat, this.lng)
    }
    this.map = new google.maps.Map(this.node, options)
    for item in this.markers
      pos = new google.maps.LatLng(item.lat, item.lng)
      marker = new google.maps.Marker({
        position: pos,
        map: this.map,
        icon: item.image
      })
    this.isCreate = true

  exitDocument: ->
    if this.srcNode not null
      if !!this.srcNode.parentNode
        this.srcNode.parentNode.removeChild(this.srcNode)

  addIcon: (lat, lng, image) ->
    this.markers.push({
      lat: lat,
      lng: lng,
      image: image
    })


ns.createMap = ->
  return new ns.Map()
