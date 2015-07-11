Backbone = require 'backbone'
InvoiceRouter = require './router.coffee'
Invoice = require '../../../models/invoice.coffee'
Merchant = require '../../../models/merchant.coffee'
InvoiceLineItems = require '../../../collections/invoice_line_items.coffee'
{ MERCHANT, INVOICE, INVOICE_LINE_ITEMS } = require('sharify').data

module.exports.init = ->
  merchant = new Merchant MERCHANT
  invoice = new Invoice INVOICE
  invoiceLineItems = new InvoiceLineItems INVOICE_LINE_ITEMS

  router = new InvoiceRouter merchant, invoice, invoiceLineItems
  Backbone.history.start pushState: true
