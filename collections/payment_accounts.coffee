_ = require 'underscore'
Backbone = require 'backbone'
PaymentAccount = require '../models/payment_account.coffee'
{ API_URL } = require('sharify').data

module.exports = class PaymentAccounts extends Backbone.Collection

  model: PaymentAccount

  url: "#{API_URL}/api/v1/payment_accounts"
