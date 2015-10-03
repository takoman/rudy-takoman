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
{ APP_URL, API_URL } = require('sharify').data

module.exports = class Order extends Backbone.Model

  _.extend @prototype, Relations
  _.extend @prototype, SantaModel

  defaults: ->
    currency_target: 'TWD'

  urlRoot: ->
    "#{API_URL}/api/v1/orders"

  url: ->
    return @urlRoot() if @isNew()
    url = "#{@urlRoot()}/#{@id}"
    url = "#{url}?access_key=#{accessKey}" if (accessKey = @get('access_key'))?
    url

  href: -> "#{APP_URL}/orders/#{@get('_id')}"

  shippingAddress: ->
    [
      @get('shipping_address')?.zipcode,
      @get('shipping_address')?.city,
      @get('shipping_address')?.district,
      @get('shipping_address')?.address,
      @get('shipping_address')?.address_2
    ].join('')

  statusLabel: ->
    switch @get('status')
      when 'new' then '新訂單'
      when 'invoiced' then '等待付款'
      when 'paid' then '已付款'
      when 'appended' then '新增項目'
      else ''
