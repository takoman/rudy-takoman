_ = require 'underscore'
Backbone = require 'backbone'
{ API_URL } = require('sharify').data

module.exports = class InvoiceLineItem extends Backbone.Model

  urlRoot: "#{API_URL}/api/v1/invoice_line_items"
