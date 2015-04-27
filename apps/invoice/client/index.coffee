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
      oli = invoiceLineItem.get('order_line_item')
      orderLineItem = new OrderLineItem(id: oli._id)
      product = new Product(id: oli.product) if oli.product?
      $.when(
        orderLineItem.fetch(),
        product?.fetch()  # When the item is not a product, this will be undefined.

      ).done((resOrderLineItem, resProduct) ->
        # resOrderLineItem is an array of [data, textStatus, xhr]
        # resProduct is an array of [data, textStatus, xhr]
        if product?
          $("tr[data-invoice-line-item-id='#{invoiceLineItem.get('_id')}'] .invoice-line-item-image").html "<img src='#{product.get('images')?[0]?.original}'>"
          $("tr[data-invoice-line-item-id='#{invoiceLineItem.get('_id')}'] .invoice-line-item-details").text "#{product.get('title')}"

      ).fail((xhr, textStatus, error) ->
        # In the multiple-Deferreds case where one of the Deferreds is rejected,
        # jQuery.when() immediately fires the failCallbacks for its master
        # Deferred. In this case, we may want to cancel unfinished ajax requests.
        undefined
      )

module.exports.init = ->
  new InvoiceView
    el: $('body')
