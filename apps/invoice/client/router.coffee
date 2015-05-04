Backbone = require 'backbone'
sd = require('sharify').data
InvoiceLineItems = require '../../../collections/invoice_line_items.coffee'
OrderLineItem = require '../../../models/order_line_item.coffee'
Product = require '../../../models/product.coffee'
CheckoutHeaderView = require '../../../components/checkout_header/view.coffee'
InvoiceConfirmationView = require './confirmation.coffee'

module.exports = class InvoiceRouter extends Backbone.Router
  routes:
    'invoices/:id': 'invoiceConfirmation'

  initialize: (invoice, invoiceLineItems) ->
    @invoice = invoice
    @invoiceLineItems = invoiceLineItems
    @initializeBanner()

  initializeBanner: ->
    new CheckoutHeaderView el: $('.checkout-header')

  invoiceConfirmation: ->
    new InvoiceConfirmationView
      el: $('.invoice-confirmation')
      invoice: @invoice
      invoiceLineItems: @invoiceLineItems
