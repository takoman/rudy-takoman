#
# Model for GitHub "orderLineItem".
#
# [Sharify](https://github.com/artsy/sharify) lets us require the API url
# and Backbone.sync is replaced with a server-side HTTP module in /lib/setup
# using [Backbone Super Sync](https://github.com/artsy/backbone-super-sync).
# This combined with [browerify](https://github.com/substack/node-browserify)
# makes it simple to share this module in the browser and on the server.
#

_ = require 'underscore'
Backbone = require 'backbone'
{ API_URL } = require('sharify').data

module.exports = class OrderLineItem extends Backbone.Model
  urlRoot = ->
    "#{API_URL}/api/v1/orders"