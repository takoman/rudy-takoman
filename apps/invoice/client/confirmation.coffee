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
      oli = invoiceLineItem.get 'order_line_item'
      product = new Product(id: oli.product) if oli.product?
      product?.fetch()  # When the item is not a product, this will be undefined.
        .done((data, textStatus, xhr) ->
          $ili = $("[data-invoice-line-item-id='#{invoiceLineItem.get('_id')}']")
          $ili.find('.invoice-line-item-image').html "<img src='#{product.get('images')?[0]?.original}'>"
          $ili.find('.invoice-line-item-brand').text "#{product.get('brand')}"
          $ili.find('.invoice-line-item-title').text "#{product.get('title')}"
        ).fail((xhr, textStatus, error) -> undefined)

  goToShipping: ->
    Backbone.history.navigate "#{@invoice.href()}/shipping", trigger: true
