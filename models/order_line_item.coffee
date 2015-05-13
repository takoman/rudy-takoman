_ = require 'underscore'
Backbone = require 'backbone'
{ API_URL } = require('sharify').data

module.exports = class OrderLineItem extends Backbone.Model

  defaults: ->
    price: 0
    quantity: 0

  urlRoot: "#{API_URL}/api/v1/order_line_items"
