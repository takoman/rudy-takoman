#
# The client-side code for the orders/create page.
#
# [Browserify](https://github.com/substack/node-browserify) lets us write this
# code as a common.js module, which means requiring dependecies instead of
# relying on globals. This module exports the Backbone view and an init
# function that gets used in /assets/commits.coffee. Doing this allows us to
# easily unit test these components, and makes the code more modular and
# composable in general.
#
_        = require 'underscore'
Backbone = require "backbone"
Backbone.$ = $
sd = require("sharify").data
Order = require "../../models/order.coffee"
orderLineItemTemplate = -> require("./templates/order_line_item_form.jade") arguments...
{ API_URL } = require('sharify').data

module.exports.OrderFormView = class OrderFormView extends Backbone.View

  initialize: ->
    @itemCount = 0
    @currencySource = 'TWD'
    @exchangeRate = '0.00'

  render: =>

  events:
    'click #btn-add-product': 'addProduct'
    'click #btn-add-commission': 'addCommission'
    'click #btn-add-shipping': 'addShipping'
    'click #order-submit': 'createOrder'
    'click #btn-set-exchange-rate': 'setExchangeRate'

  itemAdd: (e) ->
    @itemCount++

  setExchangeRate: (e) ->
    @currencySource = $('#currency-source').val()
    @exchangeRate = $('#exchange-rate').val()
    if (isNaN @exchangeRate) or !@exchangeRate
      $('#step2-block').hide()
      $('#currency-msg').html '<span class="text-danger">請輸入正確匯率</span>'
    else
      console.log @exchangeRate
      $('#currency-msg').html '已設定外幣為'+@currencySource+'，對台幣匯率為：'+@exchangeRate
      $('#step2-block').show()
      $('#step1-block').slideUp()

  addProduct: (e) ->
    $('#order-data').append (new OrderLineItemView(type: 'product', id: @itemCount, currencySource: @currencySource, exchangeRate: @exchangeRate)).el
    @itemAdd()

  addCommission: (e) ->
    $('#order-data').append (new OrderLineItemView(type: 'commission', id: @itemCount, currencySource: @currencySource, exchangeRate: @exchangeRate)).el
    @itemAdd()

  addShipping: (e) ->
    $('#order-data').append (new OrderLineItemView(type: 'shipping', id: @itemCount, currencySource: @currencySource, exchangeRate: @exchangeRate)).el
    @itemAdd()

  createOrder: (e) ->
    (new Order(
      currency_source: 'USD'
      currency_target: 'TWD'
    )).save({},
      url: "#{API_URL}/api/v1/orders"
      success: (model, response, options) -> 
        console.log 'success!'
        console.log response
      error: (model, response, options) -> 
        console.log 'error!'
        console.log model
        console.log response
    )
    false

module.exports.OrderLineItemView = class OrderLineItemView extends Backbone.View

  initialize: (options) ->
    { @type, @id, @currencySource, @exchangeRate } = options
    @render()
    @currency = 'TWD'
    @$priceField = @$el.find("input.price-field")
    @$pricehelpBlock = @$el.find('.price-help')

  render: ->
    @$el.html orderLineItemTemplate(type: @type, id: @id, currencySource: @currencySource, exchangeRate: @exchangeRate)
  
  re_calculate: ->
    @currency = @$el.find("input[name=currency_source_#{@id}]:checked").val()
    @price = @$priceField.val()
    if (@price != null) && (@price != '')
      if (isNaN @price) or (!@price)
        @$pricehelpBlock.html '<span class="text-danger">請輸入正確金額（純數字，不用加逗號）</span>'
      else
        if @currency == 'TWD'
          @$pricehelpBlock.html "顯示金額為： TWD #{@price}"
        else
          price = Math.round(parseFloat(@price) * parseFloat(@exchangeRate))
          @$pricehelpBlock.html "顯示金額為： #{@price} (#{@currency}) * #{@exchangeRate} = #{price} (TWD)"
    else
      @$pricehelpBlock.html ''

  events:
    'click .remove-item': 'remove'
    'change .currency-source-field': 're_calculate'
    'keyup input.price-field': 're_calculate'
module.exports.init = ->
  new OrderFormView
    el: $ "body"
