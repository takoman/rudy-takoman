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
          res.render 'index', invoice: invoice, invoiceLineItems: invoiceLineItems
        error: -> next()
    error: -> next()