_        = require 'underscore'
Backbone = require "backbone"
sd = require("sharify").data
Order = require "../../../models/order.coffee"
OrderLineItem = require "../../../models/order_line_item.coffee"
OrderLineItems = require "../../../collections/order_line_items.coffee"
CurrentUser = require "../../../models/current_user.coffee"
OrderLineItemView = require './order_line_item_view.coffee'
orderLineItemTemplate = -> require("../templates/order_line_item_form.jade") arguments...
{ API_URL, ORDER, ORDER_LINE_ITEMS } = require('sharify').data

module.exports.OrderFormView = class OrderFormView extends Backbone.View

  initialize: (options) ->
    { @order, @orderLineItems } = options
    @user = CurrentUser.orNull()

    @listenTo @order, 'change', @orderChanged
    @listenTo @orderLineItems, 'change add remove', @updateTotal

  events:
    'submit #form-set-exchange-rate': 'setOrderExchangeRate'
    'click #edit-exchange-rate': 'startEditingOrderExchangeRate'
    'click #add-product': 'addProduct'

  startEditingOrderExchangeRate: ->
    @$('.exchange-rate-settings').attr 'data-state', 'editing'

  setOrderExchangeRate: (e) ->
    e.preventDefault()
    @order.set
      currency_source: @$('select#currency-source').val()
      exchange_rate: @$('input#exchange-rate').val()
    @$('.exchange-rate-results .currency-source').text @order.get 'currency_source'
    @$('.exchange-rate-results .exchange-rate').text @order.get 'exchange_rate'
    @$('.exchange-rate-settings').removeAttr 'data-state'
    @$('.panel-order-line-items').removeClass('panel-disabled').addClass 'panel-secondary'

  updateTotal: ->
    types = ['product', 'shipping', 'commission']
    itemsByType = _.pick @orderLineItems.groupBy('type'), types

    # We can move the calculation to the OrderLineItems collection model.
    subtotalByType = _.mapObject itemsByType, (items, type) ->
      _.reduce items, ((m, i) -> m + i.get('quantity') * i.get('price')), 0

    _.each subtotalByType, (subtotal, type) => @$("#order-#{type}-total").text subtotal
    @$('#order-total').text _.reduce subtotalByType, ((m, t) -> m + t), 0

  orderChanged: -> undefined

  addProduct: ->
    itemView = new OrderLineItemView
      type: 'product'
      order: @order
      model: @orderLineItems.add new OrderLineItem()

    itemView.edit()
    @$('.panel-order-line-items .order-line-items').append itemView.el

module.exports.init = ->
  new OrderFormView
    el: $ "body"
    order: new Order ORDER
    orderLineItems: new OrderLineItems ORDER_LINE_ITEMS
