_ = require 'underscore'
_s = require 'underscore.string'
Backbone = require 'backbone'
InvoiceLineItem = require '../models/invoice_line_item.coffee'
{ API_URL } = require('sharify').data

module.exports = class InvoiceLineItems extends Backbone.Collection

  TYPES: ['product', 'shipping', 'commission']

  model: InvoiceLineItem

  url: "#{API_URL}/api/v1/invoice_line_items"

  numberOfProducts: ->
    @reduce (m, i) ->
      if i.get('order_line_item')?.type is 'product' then m + 1 else m
    , 0

  # Calculate the total of recognized item type
  total: ->
    @reduce (m, i) =>
      if _.contains @TYPES, i.get('order_line_item')?.type
        m + i.get('quantity') * i.get('price')
      else
        0
    , 0.00

  allpayItemName: ->
    itemNames = _.compact(@map (i) ->
      if i.get('order_line_item')?.type is 'product'
        "#{i.get('order_line_item').product?.title} x #{i.get('quantity')}"
      else
        ''
    ).join('#')

    _s.truncate itemNames, 197
