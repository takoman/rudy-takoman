_ = require 'underscore'
Backbone = require 'backbone'
Merchant = require '../models/merchant.coffee'
{ API_URL } = require('sharify').data

module.exports = class Merchants extends Backbone.Collection

  model: Merchant

  url: "#{API_URL}/api/v1/merchants"
