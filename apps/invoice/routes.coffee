#
# Routes file that exports route handlers for ease of testing.
#

Invoice = require '../../models/invoice.coffee'
InvoiceLineItems = require '../../collections/invoice_line_items.coffee'

@index = (req, res, next) ->
  invoice = new Invoice id: req.params.id
  invoice.fetch
    success: (model, response, options) ->
      invoiceLineItems = new InvoiceLineItems()
      invoiceLineItems.fetch
        data: { invoice_id: invoice.get('_id') }
        success: (collection, response, options) ->
          res.locals.sd.INVOICE = invoice.toJSON()
          res.locals.sd.INVOICE_LINE_ITEMS = invoiceLineItems.toJSON()
          res.render 'index', step: req.params.step, invoice: invoice, invoiceLineItems: invoiceLineItems
        error: -> next()
    error: -> next()

@shipping = (req, res, next) =>
  req.params.step = 'shipping'
  @index req, res, next

@payment = (req, res, next) =>
  req.params.step = 'payment'
  @index req, res, next
