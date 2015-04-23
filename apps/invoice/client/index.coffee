Backbone = require 'backbone'
sd = require('sharify').data
InvoiceLineItems = require '../../../collections/invoice_line_items.coffee'
OrderLineItem = require '../../../models/order_line_item.coffee'
Product = require '../../../models/product.coffee'

module.exports.InvoiceView = class InvoiceView extends Backbone.View

  initialize: ->
    @renderInvoiceLineItems()

  renderInvoiceLineItems: ->
    @invoiceLineItems = new InvoiceLineItems(sd.INVOICE_LINE_ITEMS)
    @invoiceLineItems.each (invoiceLineItem) ->
      new OrderLineItem(id: invoiceLineItem.get('order_line_item')).fetch
        success: (model, response, options) ->
          if model.get('type') is 'product'
            new Product(id: model.get('product')).fetch
              success: (model, response, options) ->
                $("tr[data-invoice-line-item-id='#{invoiceLineItem.get('_id')}'] .invoice-line-item-image").html "<img src='#{model.get('images')?[0]?.original}'>"
                $("tr[data-invoice-line-item-id='#{invoiceLineItem.get('_id')}'] .invoice-line-item-details").text "#{model.get('title')}"
              error: (model, response, options) -> undefined
        error: -> undefined

module.exports.init = ->
  new InvoiceView
    el: $('body')
