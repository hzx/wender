

###
Google analytics functional
###
class ns.Statistic

  constructor: ->
    @account = null
    @domain = null
    window._gaq = window._gaq || []

  ###
  var _gaq = _gaq || [];

  _gaq.push(['_setAccount', 'UA-00000001-1']);

  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();
  ###
  _initInternal: =>
    window.clearTimeout(@timeout)

    window._gaq.push(
      ['_setAccount', @account],
      ['_trackPageview'],
      ['_setDomainName', @domain]
    )

    # create script
    ga = document.createElement('script')
    ga.type = 'text/javascript'
    ga.async = true
    ga.src = (if 'https:' == document.location.protocol then 'https://ssl' else 'http://www') + '.google-analytics.com/ga.js'
    document.body.appendChild(ga)

  init: (account, domain) ->
    @account = account
    @domain = domain
    # deferred init
    @timeout = window.setTimeout(this._initInternal, 600)

  track: (category, name, value) ->
    window._gaq.push('_trackEvent', category, name, value)
