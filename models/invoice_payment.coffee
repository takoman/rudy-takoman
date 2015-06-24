_ = require 'underscore'
Backbone = require 'backbone'
SantaModel = require './mixins/santa_model.coffee'
{ API_URL, APP_URL } = require('sharify').data

module.exports = class InvoicePayment extends Backbone.Model

  _.extend @prototype, SantaModel

  urlRoot: "#{API_URL}/api/v1/invoice_payments"
