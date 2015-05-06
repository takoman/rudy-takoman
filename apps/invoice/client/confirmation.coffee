_ = require 'underscore'
Backbone = require 'backbone'
moment = require 'moment'
InvoiceLineItems = require '../../../collections/invoice_line_items.coffee'
OrderLineItem = require '../../../models/order_line_item.coffee'
Product = require '../../../models/product.coffee'
CheckoutHeaderView = require '../../../components/checkout_header/view.coffee'
template = -> require('../templates/confirmation.jade') arguments...

module.exports = class ConfirmationView extends Backbone.View
  initialize: ({ el, invoice, invoiceLineItems }) ->
    @invoice = invoice
    @invoiceLineItems = invoiceLineItems
    @render()

  events:
    'click a.confirm-invoice': 'goToShipping'

  render: ->
    # Don't render the template again if it's already rendered,
    # for example, from the back end.
    unless @$('.invoice-confirmation').length > 0
      @$el.html template
        _: _
        moment: moment
        invoice: @invoice
        invoiceLineItems: @invoiceLineItems

    @renderInvoiceLineItems @invoiceLineItems

  renderInvoiceLineItems: ->
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
          $("[data-invoice-line-item-id='#{invoiceLineItem.get('_id')}'] .invoice-line-item-image").html "<img src='#{product.get('images')?[0]?.original}'>"
          $("[data-invoice-line-item-id='#{invoiceLineItem.get('_id')}'] .invoice-line-item-brand").text "#{product.get('brand')}"
          $("[data-invoice-line-item-id='#{invoiceLineItem.get('_id')}'] .invoice-line-item-title").text "#{product.get('title')}"

      ).fail((xhr, textStatus, error) ->
        # In the multiple-Deferreds case where one of the Deferreds is rejected,
        # jQuery.when() immediately fires the failCallbacks for its master
        # Deferred. In this case, we may want to cancel unfinished ajax requests.
        undefined
      )

  goToShipping: ->
    Backbone.history.navigate "#{@invoice.href()}/shipping", trigger: true
