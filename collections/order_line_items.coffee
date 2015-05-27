_ = require 'underscore'
Backbone = require 'backbone'
OrderLineItem = require '../models/order_line_item.coffee'
{ API_URL } = require('sharify').data

module.exports = class OrderLineItems extends Backbone.Collection

  model: OrderLineItem

  url: "#{API_URL}/api/v1/order_line_items"
