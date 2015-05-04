Backbone = require 'backbone'
InvoiceRouter = require './router.coffee'
Invoice = require '../../../models/invoice.coffee'
InvoiceLineItems = require '../../../collections/invoice_line_items.coffee'
{ INVOICE, INVOICE_LINE_ITEMS } = require('sharify').data

module.exports.init = ->
  invoice = new Invoice INVOICE
  invoiceLineItems = new InvoiceLineItems INVOICE_LINE_ITEMS

  router = new InvoiceRouter invoice, invoiceLineItems
  Backbone.history.start pushState: true
