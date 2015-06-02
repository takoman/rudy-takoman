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

  numberOfProducts: ->
    @reduce (m, i) ->
      if i.get('order_line_item')?.type is 'product' then m + 1 else m
    , 0

  # Calculate the total of recognized item type
  total: ->
    @reduce (m, i) =>
      isValidType = _.contains @orderLineItemTypes, i.get('order_line_item')?.type
      return m + i.get('quantity') * i.get('price') if isValidType
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
