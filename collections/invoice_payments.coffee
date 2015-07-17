_ = require 'underscore'
Backbone = require 'backbone'
InvoicePayment = require '../models/invoice_payment.coffee'
{ API_URL } = require('sharify').data

module.exports = class InvoicePayments extends Backbone.Collection

  model: InvoicePayment

  url: "#{API_URL}/api/v1/invoice_payments"
