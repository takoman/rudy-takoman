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
  require '../../lib/vendor/tooltip.js'
  $.ajaxSettings.headers =
    'X-XAPP-TOKEN'  : sd.TAKOMAN_XAPP_TOKEN
    'X-ACCESS-TOKEN': sd.CURRENT_USER?.accessToken

# Setup global behaviors
setupGlobal = ->
  $('[data-toggle="tooltip"]').tooltip()

setupAnalytics = ->
  analytics(ga: ga)
  analytics.trackPageview()
  analytics.registerCurrentUser()
