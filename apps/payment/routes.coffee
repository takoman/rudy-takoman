_ = require 'underscore'
Q = require 'q'
InvoicePayments = require '../../collections/invoice_payments.coffee'
Invoice = require '../../models/invoice.coffee'

@paymentConfirmation = (req, res, next) ->
  # TODO: require an access key for this route.
  invoiceId = req.params.id
  invoice = new Invoice _id: invoiceId
  invoicePayments = new InvoicePayments()
  Q.all( _.map [invoice.fetch(), invoicePayments.fetch(data: invoice_id: invoiceId)], (p) -> Q(p) )
    .then ->
      # Use the last InvoicePayment object; maybe we need a better way to
      # determine which payment actually reflects the current state of the
      # invoice?
      invoicePayment = invoicePayments.last()
      res.locals.sd.INVOICE = invoice.toJSON()
      res.locals.sd.INVOICE_PAYMENT = invoicePayment.toJSON()
      res.render 'confirmation', invoice: invoice, invoicePayment: invoicePayment
    .catch (error) ->
      next error?.body?.message or 'failed to fetch invoice and payment'
    .done()
