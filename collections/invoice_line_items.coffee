_ = require 'underscore'
_s = require 'underscore.string'
Backbone = require 'backbone'
InvoiceLineItem = require '../models/invoice_line_item.coffee'
OrderLineItemTypes = require '../models/mixins/order_line_item_types.coffee'
{ API_URL } = require('sharify').data

module.exports = class InvoiceLineItems extends Backbone.Collection

  _.extend @prototype, OrderLineItemTypes

  model: InvoiceLineItem

  url: "#{API_URL}/api/v1/invoice_line_items"

  comparator: (item) ->
    types = ['product', 'shipping', 'commission']
    index = _.indexOf types, item.get('order_line_item')?.type
    return if index is -1 then types.length else index

  numberOfProducts: ->
    @reduce (m, i) ->
      if i.get('order_line_item')?.type is 'product' then m + 1 else m
    , 0

  # Calculate the total of recognized item type
  total: (type) ->
    types = if type? then [type] else @orderLineItemTypes
    @reduce (m, i) ->
      return m + i.get('quantity') * i.get('price') if _.contains(types, i.get('order_line_item')?.type)
      m
    , 0

  allpayItemName: ->
    itemNames = _.compact(@map (i) ->
      if i.get('order_line_item')?.type is 'product'
        "#{i.get('order_line_item').product?.title} x #{i.get('quantity')}"
      else
        ''
    ).join('#')

    _s.truncate itemNames, 197
