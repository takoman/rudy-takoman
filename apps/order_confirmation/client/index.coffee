_ = require 'underscore'
Q = require 'q'
Backbone = require 'backbone'
moment = require 'moment'
Invoice = require '../../../models/invoice.coffee'
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
    'submit form.confirm-order': 'confirmOrder'

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

  confirmOrder: (e) ->
    return if ($form = $(e.currentTarget)).data('submitting') is 'true'

    $form.addClass('is-loading').attr 'submitting', 'true'
    invoice = new Invoice
      order: @order.get('_id')
      due_at: moment().add(7, 'days').utc().toISOString()
      notes: ''
    Q(invoice.save())
      .then ->
        location.href = "#{invoice.href()}/shipping?access_key=#{invoice.get('access_key')}"
      .catch (error) ->
        console.log error
      .done()
    false

module.exports.init = ->
  new OrderConfirmationView
    el: $ "body"
    order: new Order ORDER
    orderLineItems: new OrderLineItems ORDER_LINE_ITEMS
