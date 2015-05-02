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
sd = require("sharify").data
Order = require "../../models/order.coffee"
OrderLineItem = require "../../models/order_line_item.coffee"
CurrentUser = require "../../models/current_user.coffee"
orderLineItemTemplate = -> require("./templates/order_line_item_form.jade") arguments...
{ API_URL } = require('sharify').data

module.exports.OrderFormView = class OrderFormView extends Backbone.View

  initialize: ->
    @user = CurrentUser.orNull()
    @total = 0
    @totalProduct = 0
    @totalShipping = 0
    @totalCommission = 0
    @currencySource = 'TWD'
    @exchangeRate = '0.00'
    @orderLineItems = []
    @setWaypoint()

  setWaypoint: ->
    @waypoint = $('#add-item-bar-position').waypoint(
      (direction) ->
        if direction is 'down'
          $('#add-item-bar').removeClass('add-item-bar-fixed')
        if direction is 'up'
          $('#add-item-bar').addClass('add-item-bar-fixed')
      , offset: 'bottom-in-view'
    )

  resetWaypoint: ->
    Waypoint.refreshAll()

  events:
    'click #btn-add-product': 'addProduct'
    'click #btn-add-commission': 'addCommission'
    'click #btn-add-shipping': 'addShipping'
    'click #order-submit': 'createOrder'
    'click #btn-set-exchange-rate': 'setCurrencyExchangeRate'
    'click #edit-step1': 'editStep1'

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

module.exports.OrderLineItemView = class OrderLineItemView extends Backbone.View

  initialize: (options) ->
    { @type, @id, @currencySource, @exchangeRate } = options
    @render()
    @currency = 'TWD'
    @$priceField = @$el.find('input.price-field')
    @$pricePreviewField = @$el.find('.preview-price')
    @$priceHelpBlock = @$el.find('.price-help')
    @$quantityField = @$el.find('input.quantity-field')
    @$quantityHelpBlock = @$el.find('.quantity-help')
    @price = 0
    @quantity = 1
    @twdPrice = 0
    @twdPricePreview = 0
    @saved = false

  resetCurrencyExchangeRate: ->
    @$el.find('.currency-source-field').val(@currencySource)
    @$el.find('.currency-source-text').html(@currencySource)
    if @saved
      @pricePreview()
      @setPrice()
    else
      @pricePreview()

  render: ->
    @$el.html orderLineItemTemplate(type: @type, id: @id, currencySource: @currencySource, exchangeRate: @exchangeRate)

  pricePreview: ->
    @currency = @$el.find("input[name=currency_source_#{@id}]:checked").val()
    @quantity = @$quantityField.val()
    price = @$priceField.val()
    if (price != null) && (price != '') && (@quantity != null) && (@quantity != '')
      if (isNaN @quantity)
        @$quantityHelpBlock.html '<span class="text-danger">請輸入正確數量（純數字，不用加逗號）</span>'
      else if (isNaN price) or (!price)
        @$priceHelpBlock.html '<span class="text-danger">請輸入正確金額（純數字，不用加逗號）</span>'
      else
        if @currency == 'TWD'
          @twdPricePreview = price * @quantity
          if @quantity == 1
            @$priceHelpBlock.html "顯示金額為：NT. #{@twdPricePreview}"
          else
            @$priceHelpBlock.html "顯示金額為：#{price} * #{@quantity} = NT. #{@twdPricePreview}"
        else
          @twdPricePreview = Math.round(parseFloat(price) * parseFloat(@exchangeRate)) * @quantity
          if @quantity == 1
            @$priceHelpBlock.html "顯示金額為： #{price} (#{@currency}) * #{@exchangeRate} = NT. #{@twdPricePreview}"
          else
            @$priceHelpBlock.html "顯示金額為： #{price} (#{@currency}) * #{@exchangeRate} *#{@quantity}= NT. #{@twdPricePreview}"
    else
      @$priceHelpBlock.html ''

  setPrice: ->
    @currency = @$el.find("input[name=currency_source_#{@id}]:checked").val()
    price = @$priceField.val()
    if (@type == 'commission' || @type == 'shipping')
      @quantity = 1
    else
      @quantity = @$quantityField.val()
    if (@quantity == null) or (@quantity == '') or (isNaN @quantity) or (!@quantity)
      @$quantityField.focus()
      false
    else
      if (price == null) or (price == '') or (isNaN price) or (!price)
        @$priceField.focus()
        false
      else
        if @currency == 'TWD'
          @twdPrice = @twdPricePreview = price * @quantity
          @price = price
          if @quantity == 1
            @$priceHelpBlock.html "顯示金額為：NT. #{@twdPricePreview}"
          else
            @$priceHelpBlock.html "顯示金額為：#{price} * #{@quantity} = NT. #{@twdPricePreview}"
        else
          @twdPrice = @twdPricePreview = Math.round(parseFloat(price) * parseFloat(@exchangeRate)) * @quantity
          @price = Math.round(parseFloat(price) * parseFloat(@exchangeRate))
          if @quantity == 1
            @$priceHelpBlock.html "顯示金額為： #{price} (#{@currency}) * #{@exchangeRate} = NT. #{@twdPricePreview}"
          else
            @$priceHelpBlock.html "顯示金額為： #{price} (#{@currency}) * #{@exchangeRate} *#{@quantity}= NT. #{@twdPricePreview}"
        @$pricePreviewField.html "NT. #{@twdPricePreview} (TWD)"
        true

  editItem: ->
    @$el.find(".order-line-item-form").show()
    @$el.find(".order-line-item-preview").hide()
    @saved = false
    @.trigger('itemChanged')

  saveItem: ->
    if @setPrice()
      @saved = true
      if (@type == 'product')
        @$el.find(".preview-brand").html(@$el.find("input[name=brand_#{@id}]").val())
        @$el.find(".preview-title").html(@$el.find("input[name=title_#{@id}]").val())
        #@$el.find(".preview-url").html(@$el.find("input[name=urls_#{@id}]").val())
        #@$el.find(".preview-image").html(@$el.find("input[name=images_#{@id}]").val())
        @$el.find(".preview-color-size").html(@$el.find("input[name=color_size_#{@id}]").val())
        @$el.find(".preview-quantity").html(@$el.find("input[name=quantity_#{@id}]").val())
        #@$el.find(".preview-notes").html(@$el.find("textarea[name=notes_#{@id}]").val())
      if (@type == 'commission' || @type == 'shipping')
        @$el.find(".preview-notes").html(@$el.find("textarea[name=notes_#{@id}]").val())
      @$el.find(".order-line-item-preview").show()
      @$el.find(".order-line-item-form").hide()
      @.trigger('itemChanged')
      console.log(@)

  removeItem: ->
    @price = 0
    @twdPrice = 0
    @remove()
    @.trigger('itemChanged')
    false

  events:
    'click .remove-item': 'removeItem'
    'change .quantity-field': 'pricePreview'
    'change .currency-field': 'pricePreview'
    'keyup input.price-field': 'pricePreview'
    'click .save-btn': 'saveItem'
    'click .edit-btn': 'editItem'

module.exports.init = ->
  new OrderFormView
    el: $ "body"
