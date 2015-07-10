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
  total: (type) ->
    types = if type? then [type] else @orderLineItemTypes
    @reduce (m, i) ->
      return m + i.get('quantity') * i.get('price') if _.contains(types, i.get('type'))
      m
    , 0

  comparator: (item) ->
    types = ['product', 'shipping', 'commission', 'tax']
    index = _.indexOf types, item.get('type')
    return if index is -1 then types.length else index
