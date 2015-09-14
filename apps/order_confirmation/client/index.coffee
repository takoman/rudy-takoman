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
  events:
    'change input.order-is-confirmed': 'toggleOrderConfirm'

  initialize: (options) ->
    { @order, @orderLineItems } = options
    @initializeBanner()

  initializeBanner: ->
    new CheckoutHeaderView el: $('.checkout-header')

  toggleOrderConfirm: (e) ->
    enabledClasses = 'btn-cta btn-red'
    disabledClasses = 'btn-disabled'
    if $(e.currentTarget).is(':checked')
      $('.confirm-order').removeAttr('disabled')
        .removeClass(disabledClasses).addClass(enabledClasses)
    else
      $('.confirm-order').attr('disabled', 'disabled')
        .removeClass(enabledClasses).addClass(disabledClasses)

module.exports.init = ->
  new OrderConfirmationView
    el: $ "body"
    order: new Order ORDER
    orderLineItems: new OrderLineItems ORDER_LINE_ITEMS
