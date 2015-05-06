Backbone = require 'backbone'
InvoiceLineItems = require '../../../collections/invoice_line_items.coffee'
OrderLineItem = require '../../../models/order_line_item.coffee'
Product = require '../../../models/product.coffee'
CheckoutHeaderView = require '../../../components/checkout_header/view.coffee'
template = -> require('../templates/shipping.jade') arguments...

module.exports = class ShippingView extends Backbone.View
  initialize: ({ el, invoice, invoiceLineItems }) ->
    @invoice = invoice
    @invoiceLinItems = invoiceLineItems
    @render()

  render: ->
    @$el.html template
