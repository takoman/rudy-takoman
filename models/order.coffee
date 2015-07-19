#
# Model for GitHub "order".
#
# [Sharify](https://github.com/artsy/sharify) lets us require the API url
# and Backbone.sync is replaced with a server-side HTTP module in /lib/setup
# using [Backbone Super Sync](https://github.com/artsy/backbone-super-sync).
# This combined with [browerify](https://github.com/substack/node-browserify)
# makes it simple to share this module in the browser and on the server.
#

_ = require 'underscore'
Backbone = require 'backbone'
Relations = require './mixins/relations/order.coffee'
SantaModel = require './mixins/santa_model.coffee'
{ API_URL } = require('sharify').data

module.exports = class Order extends Backbone.Model

  _.extend @prototype, Relations
  _.extend @prototype, SantaModel

  defaults: ->
    currency_target: 'TWD'

  urlRoot: ->
    "#{API_URL}/api/v1/orders"

  shippingAddress: ->
    [
      @get('shipping_address')?.zipcode,
      @get('shipping_address')?.city,
      @get('shipping_address')?.district,
      @get('shipping_address')?.address,
      @get('shipping_address')?.address_2
    ].join('')
