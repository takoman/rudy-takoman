Backbone        = require 'backbone'
Backbone.$      = $
_               = require 'underscore'
sd              = require('sharify').data
analytics       = require '../../lib/analytics.coffee'

module.exports = ->
  setupJquery()
  setupGlobal()
  setupAnalytics()

setupJquery = ->
  require 'typeahead.js/dist/typeahead.bundle.min.js'
  require 'jquery.transition'
  require 'waypoints/lib/jquery.waypoints.min.js'
  require 'waypoints/lib/shortcuts/sticky.min.js'
  require '../../lib/vendor/transition.js'
  require '../../lib/vendor/tooltip.js'
  require '../../lib/vendor/tab.js'
  require '../../lib/vendor/jquery.are-you-sure.js'
  $.ajaxSettings.headers =
    'X-XAPP-TOKEN'  : sd.TAKOMAN_XAPP_TOKEN
    'X-ACCESS-TOKEN': sd.CURRENT_USER?.accessToken

# Setup global behaviors
setupGlobal = ->
  $('[data-toggle="tooltip"]').tooltip container: 'body'

setupAnalytics = ->
  analytics(ga: ga) if ga?
  analytics.trackPageview()
  analytics.registerCurrentUser()
