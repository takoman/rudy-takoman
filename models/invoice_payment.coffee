_ = require 'underscore'
Backbone = require 'backbone'
{ API_URL, APP_URL } = require('sharify').data

module.exports = class InvoicePayment extends Backbone.Model

  urlRoot: "#{API_URL}/api/v1/invoice_payments"
