_ = require 'underscore'
Backbone = require 'backbone'
OrderLineItem = require '../models/order_line_item.coffee'
OrderLineItemTypes = require '../models/mixins/order_line_item_types.coffee'
{ API_URL } = require('sharify').data

module.exports = class OrderLineItems extends Backbone.Collection

  _.extend @prototype, OrderLineItemTypes

  model: OrderLineItem

  url: "#{API_URL}/api/v1/order_line_items"

  # Calculate the total of recognized item type
  total: ->
    @reduce (m, i) =>
      return m + i.get('quantity') * i.get('price') if _.contains(@orderLineItemTypes, i.get('type'))
      m
    , 0
