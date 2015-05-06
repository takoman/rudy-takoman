_ = require 'underscore'
Backbone = require 'backbone'
{ API_URL, APP_URL } = require('sharify').data

module.exports = class Invoice extends Backbone.Model

  urlRoot: "#{API_URL}/api/v1/invoices"

  href: -> "/invoices/#{@get('_id')}"
