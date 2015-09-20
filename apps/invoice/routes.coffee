#
# Routes file that exports route handlers for ease of testing.
#

Merchant = require '../../models/merchant.coffee'
Invoice = require '../../models/invoice.coffee'
InvoiceLineItems = require '../../collections/invoice_line_items.coffee'
Q= require 'q'

@index = (req, res, next) ->
  return next() unless (accessKey = req.query.access_key)

  merchant = new Merchant()
  invoice = new Invoice _id: req.params.id
  invoiceLineItems = new InvoiceLineItems()
  Q(invoice.fetch(data: access_key: accessKey))
    .then ->
      Q.all [
        invoiceLineItems.fetch(data: invoice_id: invoice.get('_id'))
        merchant.set(_id: invoice.get('order')?.merchant).fetch()
      ]
    .then ->
      res.locals.sd.MERCHANT = merchant.toJSON()
      res.locals.sd.INVOICE = invoice.toJSON()
      res.locals.sd.INVOICE_LINE_ITEMS = invoiceLineItems.toJSON()
      res.render 'index',
        step: req.params.step
        merchant: merchant
        invoice: invoice
        invoiceLineItems: invoiceLineItems
    .catch (error) ->
      next error?.body?.message or 'failed to fetch invoice information'
    .done()

@shipping = (req, res, next) =>
  req.params.step = 'shipping'
  @index req, res, next

@payment = (req, res, next) =>
  req.params.step = 'payment'
  @index req, res, next
