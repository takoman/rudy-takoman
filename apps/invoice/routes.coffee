#
# Routes file that exports route handlers for ease of testing.
#

_ = require 'underscore'
Invoice = require '../../models/invoice.coffee'
InvoiceLineItems = require '../../collections/invoice_line_items.coffee'
AllPay = require 'allpay'
{ ALLPAY_PLATFORM_ID, ALLPAY_AIO_HASH_KEY, ALLPAY_AIO_HASH_IV } = require '../../config'

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

@allpayPaymentFormHtml = (req, res, next) ->
  allpay = new AllPay
    merchantId: ALLPAY_PLATFORM_ID
    hashKey: ALLPAY_AIO_HASH_KEY
    hashIV: ALLPAY_AIO_HASH_IV

  data = req.query
  data = _.extend data, PlatformID: ALLPAY_PLATFORM_ID
  html = allpay.createFormHtml _.extend data, CheckMacValue: allpay.genCheckMacValue(data)

  res.send html
