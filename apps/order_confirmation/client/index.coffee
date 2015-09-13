_ = require 'underscore'
Backbone = require 'backbone'
moment = require 'moment'
Order = require '../../../models/order.coffee'
OrderLineItems = require '../../../collections/invoice_line_items.coffee'
OrderLineItem = require '../../../models/order_line_item.coffee'
Product = require '../../../models/product.coffee'
CheckoutHeaderView = require '../../../components/checkout_header/view.coffee'
acct = require 'accounting'
{ ORDER, ORDER_LINE_ITEMS } = require('sharify').data

acct.settings.currency = _.defaults
  precision: 0
  symbol: 'NT'
  format: '%s %v'
, acct.settings.currency

module.exports = class OrderConfirmationView extends Backbone.View
  initialize: (options) ->
    { @order, @orderLineItems } = options

module.exports.init = ->
  new OrderConfirmationView
    el: $ "body"
    order: new Order ORDER
    orderLineItems: new OrderLineItems ORDER_LINE_ITEMS
