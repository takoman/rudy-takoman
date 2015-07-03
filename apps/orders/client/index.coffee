_ = require 'underscore'
_s = require 'underscore.string'
Q = require 'q'
Backbone = require "backbone"
Orders = require "../../../collections/orders.coffee"
{ API_URL, ORDERS } = require('sharify').data

module.exports.OrdersView = class OrdersView extends Backbone.View
  #

module.exports.init = ->
  new OrdersView
    el: $ "body"
    orders: new Orders ORDERS
