Backbone = require 'backbone'
sd = require('sharify').data
InvoiceLineItems = require '../../../collections/invoice_line_items.coffee'
OrderLineItem = require '../../../models/order_line_item.coffee'
Product = require '../../../models/product.coffee'
CheckoutHeaderView = require '../../../components/checkout_header/view.coffee'
InvoiceConfirmationView = require './confirmation.coffee'
InvoiceShippingView = require './shipping.coffee'

module.exports = class InvoiceRouter extends Backbone.Router
  routes:
    'invoices/:id': 'confirmation'
    'invoices/:id/shipping': 'shipping'

  initialize: (invoice, invoiceLineItems) ->
    @invoice = invoice
    @invoiceLineItems = invoiceLineItems
    @initializeBanner()

  initializeBanner: ->
    new CheckoutHeaderView el: $('.checkout-header')

  confirmation: ->
    new InvoiceConfirmationView
      el: $('.invoice-content')
      invoice: @invoice
      invoiceLineItems: @invoiceLineItems

  shipping: ->
    new InvoiceShippingView
      el: $('.invoice-content')
      invoice: @invoice
      invoiceLineItems: @invoiceLineItems
