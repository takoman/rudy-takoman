Backbone        = require 'backbone'
Backbone.$      = $
_               = require 'underscore'
sd              = require('sharify').data
analytics       = require '../../lib/analytics.coffee'

module.exports = ->
  setupJquery()
  setupAnalytics()

setupJquery = ->
  require 'typeahead.js/dist/typeahead.bundle.min.js'
  require 'jquery.transition'
  require 'jquery-waypoints/lib/jquery.waypoints.min.js'
  $.ajaxSettings.headers =
    'X-XAPP-TOKEN'  : sd.TAKOMAN_XAPP_TOKEN
    'X-ACCESS-TOKEN': sd.CURRENT_USER?.accessToken

setupAnalytics = ->
  analytics(ga: ga)
  analytics.trackPageview()
  analytics.registerCurrentUser()
