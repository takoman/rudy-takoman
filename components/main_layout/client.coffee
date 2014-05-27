Backbone        = require 'backbone'
Backbone.$      = $
_               = require 'underscore'
sd              = require('sharify').data

module.exports = ->
  setupJquery()

setupJquery = ->
  require 'jquery.transition'
  $.ajaxSettings.headers =
    'X-XAPP-TOKEN'  : sd.TAKOMAN_XAPP_TOKEN
    'X-ACCESS-TOKEN': sd.CURRENT_USER?.accessToken
