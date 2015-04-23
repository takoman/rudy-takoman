_ = require 'underscore'
Backbone = require 'backbone'
InvoiceLineItem = require '../models/invoice_line_item.coffee'
{ API_URL } = require('sharify').data

module.exports = class InvoiceLineItems extends Backbone.Collection

  model: InvoiceLineItem

  url: "#{API_URL}/api/v1/invoice_line_items"
