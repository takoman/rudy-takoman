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

  events:
    'click #add-product': 'addProduct'
    'submit #form-set-exchange-rate': 'setOrderExchangeRate'
    'click #edit-exchange-rate': 'startEditingOrderExchangeRate'
    #'click #btn-add-commission': 'addCommission'
    #'click #btn-add-shipping': 'addShipping'
    #'click #order-submit': 'createOrder'
    #'click #btn-set-exchange-rate': 'setCurrencyExchangeRate'
    #'click #edit-step1': 'editStep1'

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

  orderChanged: ->
    # Update all the order line items
    console.log @order









  editStep1: (e) ->
    $('#currency-msg').hide()
    $('#step1-block-2').slideUp()
    $('#step2-block-content').slideUp()
    $('#step2-block').addClass('panel-gray').removeClass('panel-default')
    $('#step1-block-1').slideDown()
    $('#edit-step1').fadeOut()

  setCurrencyExchangeRate: (e) ->
    @currencySource = $('#currency-source').val()
    @exchangeRate = $('#exchange-rate').val()
    if (isNaN @exchangeRate) or !@exchangeRate
      $('#step2-block-content').hide()
      $('#currency-msg').html '<span class="text-danger">請輸入正確匯率</span>'
      $('#currency-msg').show()
    else
      $('#currency-msg').hide()
      $('#step1-block-2').html "貨幣： #{@currencySource}<br>對台幣匯率為：#{@exchangeRate}"
      $('#step1-block-2').show()
      $('#step2-block-content').show()
      $('#step2-block').addClass('panel-default').removeClass('panel-gray')
      $('#step1-block-1').hide()
      $('#edit-step1').show()
      @resetLineItems()

  resetLineItems: (e) ->
    for lineItem in @orderLineItems
      lineItem.currencySource = @currencySource
      lineItem.exchangeRate = @exchangeRate
      lineItem.resetCurrencyExchangeRate()
    @itemsChanged()

  itemsChanged: (e) ->
    @total = 0
    @totalProduct = 0
    @totalShipping = 0
    @totalCommission = 0
    for lineItem in @orderLineItems
      @total += parseInt lineItem.twdPrice if _.contains(['product', 'shipping', 'commission'], lineItem.type)
      if lineItem.type == 'product'
        @totalProduct += parseInt lineItem.twdPrice
      if lineItem.type == 'shipping'
        @totalShipping += parseInt lineItem.twdPrice
      if lineItem.type == 'commission'
        @totalCommission += parseInt lineItem.twdPrice

    $('#total-product').html if (@totalProduct == 0) then '--' else " NT. #{@totalProduct}"
    $('#total-shipping').html if (@totalShipping == 0) then '--' else " NT. #{@totalShipping}"
    $('#total-commission').html if (@totalCommission == 0) then '--' else " NT. #{@totalCommission}"
    $('#total-all').html if (@total == 0) then '--' else " NT. #{@total}"
    @resetWaypoint()

  addProduct: (e) ->
    lineItem = new OrderLineItemView(type: 'product', id: @orderLineItems.length, currencySource: @currencySource, exchangeRate: @exchangeRate)
    @.listenTo(lineItem, 'itemChanged', @itemsChanged)
    $('#order-line-items').append (lineItem.el)
    @orderLineItems.push(lineItem)
    @resetWaypoint()

  addCommission: (e) ->
    lineItem = new OrderLineItemView(type: 'commission', id: @orderLineItems.length, currencySource: @currencySource, exchangeRate: @exchangeRate)
    @.listenTo(lineItem, 'itemChanged', @itemsChanged)
    $('#order-line-items').append (lineItem.el)
    @orderLineItems.push(lineItem)
    @resetWaypoint()

  addShipping: (e) ->
    lineItem = new OrderLineItemView(type: 'shipping', id: @orderLineItems.length, currencySource: @currencySource, exchangeRate: @exchangeRate)
    @.listenTo(lineItem, 'itemChanged', @itemsChanged)
    $('#order-line-items').append (lineItem.el)
    @orderLineItems.push(lineItem)
    @resetWaypoint()

  createOrder: (e) ->
    customer = new Backbone.Model
      name: 'Customer Name'
      email: 'Customer3@email.com'
      password: 'password'
    customer.url = -> "#{API_URL}/api/v1/users"
    customer.save {},
      success: (model, response, options) =>
        order = new Order
          currency_source: @currencySource
          currency_target: 'TWD'
          exchange_rate: @exchangeRate
          merchant: '553bb1a3e1c469034a00b0c0'
          customer: customer.get('_id')
        order.save({},
          url: "#{API_URL}/api/v1/orders"
          success: (model, response, options) =>
            _.each @orderLineItems, (item) ->
              (new OrderLineItem(
                type: item.type
                price: item.twdPrice
                quantity: item.quantity
                order: order.get('_id')
              )).save({},
                url: "#{API_URL}/api/v1/order_line_items"
                success: (model, response, options) ->
                  console.log model
              )
          error: (model, response, options) ->
            console.log 'error!'
            console.log model
            console.log response
        )
    false

module.exports.init = ->
  new OrderFormView
    el: $ "body"
    order: new Order ORDER
    orderLineItems: new OrderLineItems ORDER_LINE_ITEMS
