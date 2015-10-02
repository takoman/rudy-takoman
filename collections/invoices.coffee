_ = require 'underscore'
Backbone = require 'backbone'
Invoice = require '../models/invoice.coffee'
{ API_URL } = require('sharify').data

module.exports = class Invoices extends Backbone.Collection

  model: Invoice

  url: "#{API_URL}/api/v1/invoices"
