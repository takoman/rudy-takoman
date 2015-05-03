_ = require 'underscore'
Backbone = require 'backbone'
{ API_URL } = require('sharify').data

module.exports = class OrderLineItem extends Backbone.Model

  urlRoot: "#{API_URL}/api/v1/order_line_items"
