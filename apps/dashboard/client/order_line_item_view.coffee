_        = require 'underscore'
Backbone = require "backbone"
sd = require("sharify").data
OrderLineItem = require "../../../models/order_line_item.coffee"
CurrentUser = require "../../../models/current_user.coffee"
orderLineItemTemplate = -> require("../templates/order_line_item_form.jade") arguments...
{ API_URL } = require('sharify').data

module.exports = class OrderLineItemView extends Backbone.View

  defaults: ->
    quantity: 1
    price: 0

  initialize: (options) ->
    { @type, @order, @quantity, @price } = _.defaults options, @defaults

    @oldFXRate = @order.get 'exchange_rate'

    @listenTo @model, 'change', @render
    @listenTo @model, 'destroy', @remove
    @listenTo @order, 'change', @orderChanged

    @render()

  events:
    'click .remove-item': 'destroy'
    'submit .form-order-line-item': 'save'
    'click .edit-item': 'edit'
    'click .cancel': 'cancel'
    'change .form-order-line-item [name="currency-source"]': 'updateSubtotalMessage'
    'keyup .form-order-line-item [name="price"]': 'updateSubtotalMessage'  # TODO: throttle this

  render: ->
    @$el.html orderLineItemTemplate
      item: @model
      type: @type
      currencySource: @order.get 'currency_source'
      currencyTarget: @order.get 'currency_target'
      exchangeRate: @order.get 'exchange_rate'

    # Since we replace the entire html, we have to cache selectors everytime
    # after rendering.
    @$currencySourceFields = @$('.form-order-line-item [name="currency-source"]')
    @$priceField = @$('.form-order-line-item [name="price"]')

    @updateSubtotalMessage()

  currencySource: -> @$currencySourceFields.filter(':checked').val()

  updateSubtotalMessage: ->
    if @currencySource() is 'TWD'
      @$('.subtotal-message').empty()
    else if isNaN (price = @$priceField.val())
      @$('.subtotal-message').text "單價必須為數字"
    else
      @$('.subtotal-message').text "商品單價換算為台幣 #{price * @order.get 'exchange_rate'} 元"

  orderChanged: ->
    newFXRate = @order.get 'exchange_rate'
    @model.set 'price', @model.get('price') * newFXRate / @oldFXRate

    # last step, cache the existing exchange rate
    @oldFXRate = @order.get 'exchange_rate'

  save: (e) ->
    e.preventDefault()

    if @type is 'product'
      @model.related().product.set
        title: @$('input[name="title"]').val()
        brand: @$('input[name="brand"]').val()

    twdPrice = @$priceField.val()
    twdPrice = twdPrice * @order.get('exchange_rate') unless @currencySource() is 'TWD'
    # http://stackoverflow.com/questions/6535948/nested-models-in-backbone-js-how-to-approach
    @model.set
      type: @type
      price: twdPrice
      quantity: @$('.form-order-line-item [name="quantity"]').val()
      notes: @$('.form-order-line-item [name="notes"]').val()

    @$('.order-line-item').removeAttr 'data-state'

  destroy: ->
    # TODO: need confirmation
    @model.destroy()

  edit: -> @$('.order-line-item').attr 'data-state', 'editing'

  cancel: -> @$('.order-line-item').removeAttr 'data-state'
