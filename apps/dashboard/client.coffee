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
    @total = 0
    @productTotal = 0
    @shippingTotal = 0
    @commissionTotal = 0
    @currencySource = 'TWD'
    @exchangeRate = '0.00'
    @OrderLineItems = []

  events:
    'click #btn-add-product': 'addProduct'
    'click #btn-add-commission': 'addCommission'
    'click #btn-add-shipping': 'addShipping'
    'click #order-submit': 'createOrder'
    'click #btn-set-exchange-rate': 'setExchangeRate'

  setExchangeRate: (e) ->
    @currencySource = $('#currency-source').val()
    @exchangeRate = $('#exchange-rate').val()
    if (isNaN @exchangeRate) or !@exchangeRate
      $('#step2-block').hide()
      $('#currency-msg').html '<span class="text-danger">請輸入正確匯率</span>'
      $('#currency-msg').show()
    else
      console.log @exchangeRate
      $('#currency-msg').hide()
      $('#step1-block-2').html "貨幣： #{@currencySource}<br>對台幣匯率為：#{@exchangeRate}"
      $('#step1-block-2').fadeIn()
      $('#step2-block').show()
      $('#step1-block-1').slideUp()

  countTotal: (e) ->
    @total = 0
    @productTotal = 0
    @shippingTotal = 0
    @commissionTotal = 0
    for item in @OrderLineItems
      @total += parseInt item.twdprice
      if item.type == 'product'
        @productTotal += parseInt item.twdprice
      if item.type == 'shipping'
        @shippingTotal += parseInt item.twdprice
      if item.type == 'commission'
        @commissionTotal += parseInt item.twdprice
    $('#product-total').html ' NT '+@productTotal
    $('#shipping-total').html ' NT '+@shippingTotal
    $('#commission-total').html ' NT '+@commissionTotal

    console.log @total
    console.log @OrderLineItems

  addProduct: (e) ->
    item = new OrderLineItemView(type: 'product', id: @OrderLineItems.length, currencySource: @currencySource, exchangeRate: @exchangeRate)
    @.listenTo(item, 'totalChange', @countTotal)
    $('#order-data').append (item.el)
    @OrderLineItems.push(item)

  addCommission: (e) ->
    item = new OrderLineItemView(type: 'commission', id: @OrderLineItems.length, currencySource: @currencySource, exchangeRate: @exchangeRate)
    @.listenTo(item, 'totalChange', @countTotal)
    $('#order-data').append (item.el)
    @OrderLineItems.push(item)

  addShipping: (e) ->
    item = new OrderLineItemView(type: 'shipping', id: @OrderLineItems.length, currencySource: @currencySource, exchangeRate: @exchangeRate)
    @.listenTo(item, 'totalChange', @countTotal)
    $('#order-data').append (item.el)
    @OrderLineItems.push(item)

  createOrder: (e) ->
    (new Order(
      currency_source: @currencySource
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
    @$twdPriceField = @$el.find("input[name=twd_price_#{@id}]")
    @$pricePreviewField = @$el.find(".preview-price")
    @$pricehelpBlock = @$el.find('.price-help')
    @price = 0
    @twdprice = 0

  render: ->
    @$el.html orderLineItemTemplate(type: @type, id: @id, currencySource: @currencySource, exchangeRate: @exchangeRate)

  recalculate: ->
    @currency = @$el.find("input[name=currency_source_#{@id}]:checked").val()
    @price = @$priceField.val()
    if (@price != null) && (@price != '')
      if (isNaN @price) or (!@price)
        @$pricehelpBlock.html '<span class="text-danger">請輸入正確金額（純數字，不用加逗號）</span>'
      else
        if @currency == 'TWD'
          @twdprice = @price
          @$pricehelpBlock.html "顯示金額為： TWD #{@twdprice}"
          @$twdPriceField.val @price
          @$pricePreviewField.html "TWD #{@twdprice}"
        else
          @twdprice = Math.round(parseFloat(@price) * parseFloat(@exchangeRate))
          @$pricehelpBlock.html "顯示金額為： #{@price} (#{@currency}) * #{@exchangeRate} = #{@twdprice} (TWD)"
          @$twdPriceField.val @twdprice
          @$pricePreviewField.html "#{@price} (#{@currency}) * #{@exchangeRate} = #{@twdprice} (TWD)"
    else
      @$pricehelpBlock.html ''

  editItem: ->
    @$el.find(".form-block").show()
    @$el.find(".preview-block").hide()
    false

  saveItem: ->
    if (@type == 'product')
      @$el.find(".preview-brand").html(@$el.find("input[name=brand_#{@id}]").val())
      @$el.find(".preview-title").html(@$el.find("input[name=title_#{@id}]").val())
      @$el.find(".preview-url").html(@$el.find("input[name=urls_#{@id}]").val())
      @$el.find(".preview-image").html(@$el.find("input[name=images_#{@id}]").val())
      @$el.find(".preview-color-size").html(@$el.find("input[name=color_size_#{@id}]").val())
      @$el.find(".preview-quantity").html(@$el.find("input[name=quantity_#{@id}]").val())
      @$el.find(".preview-notes").html(@$el.find("textarea[name=notes_#{@id}]").val())
    if (@type == 'commission' || @type == 'shipping')
      @$el.find(".preview-notes").html(@$el.find("textarea[name=notes_#{@id}]").val())

    @$el.find(".preview-block").show()
    @$el.find(".form-block").hide()
    @.trigger('totalChange')

  removeItem: ->
    @price = 0
    @twdprice = 0
    @remove()
    @.trigger('totalChange')
    false

  events:
    #'click .remove-item': 'remove'
    'click .remove-item': 'removeItem'
    'change .currency-source-field': 'recalculate'
    'keyup input.price-field': 'recalculate'
    'click .save-btn': 'saveItem'
    'click .edit-btn': 'editItem'

module.exports.init = ->
  new OrderFormView
    el: $ "body"
