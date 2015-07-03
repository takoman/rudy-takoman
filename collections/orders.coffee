_ = require 'underscore'
Backbone = require 'backbone'
Order = require '../models/order.coffee'
{ API_URL } = require('sharify').data

module.exports = class Orders extends Backbone.Collection

  model: Order

  url: "#{API_URL}/api/v1/orders"
