_        = require 'underscore'
Backbone = require "backbone"
sd = require("sharify").data
OrderLineItem = require "../../../models/order_line_item.coffee"
Order = require "../../../models/order.coffee"
CurrentUser = require "../../../models/current_user.coffee"
UploadForm = require "../../../components/upload/client/index.coffee"
money = require '../../../lib/money.js'
acct = require 'accounting'
orderLineItemTemplate = -> require("../templates/order_line_item_form.jade") arguments...
imagesTemplate = -> require("../templates/item_images.jade") arguments...
{ API_URL } = require('sharify').data

module.exports = class OrderLineItemView extends Backbone.View

  isCreated: false  # True if the item has been created in the order creation UI,
                    # no matter if the item has been saved to the server or not.

  defaults: ->
    type: 'product'
    order: new Order()

  initialize: (options) ->
    { @type, @order } = _.defaults options, @defaults()

    @oldFXRate = @order.get 'exchange_rate'

    # Create a fx instance to handle currencies exchange
    @fx = money.factory()
    @setupCurrencyExchange()

    @listenTo @model, 'change', @render
    @listenTo @model, 'destroy', @remove
    @listenTo @order, 'change', @orderChanged

    @render()

  events:
    'click .remove-item': 'destroy'
    'submit .form-order-line-item': 'save'
    'click .edit-item': 'edit'
    'click .cancel-saving-item': 'cancel'
    'change .form-order-line-item [name="currency-source"]': 'updateSubtotalMessage'
    'keyup .form-order-line-item [name="price"]': 'updateSubtotalMessage'  # TODO: throttle this

  render: ->
    @$el.html orderLineItemTemplate
      _: _, fx: @fx, acct: acct, money: money  # pass in some helpers
      item: @model
      type: @type
      currencySource: @cs
      currencyTarget: @ct

    # Since we replace the entire html, we have to cache selectors everytime
    # after rendering.
    @$currencySourceFields = @$('.form-order-line-item [name="currency-source"]')
    @$priceField = @$('.form-order-line-item [name="price"]')

    @updateSubtotalMessage()
    @setupFileUpload() if @type is 'product'

  setupCurrencyExchange: ->
    # Cache the source and target currencies
    @ct = @order.get 'currency_target'
    @cs = @order.get 'currency_source'
    @fx.rates[@ct] = @order.get 'exchange_rate'
    @fx.rates[@cs] = 1
    @fx.base = @cs

  setupFileUpload: ->
    new UploadForm
      el: @$('#form-image-upload')
      onSend: -> console.log 'onSend'
      onProgress: -> console.log 'onProgress'
      onFail: -> console.log 'onFail'
      onDone: (e, data) =>
        url = $(data.result).find('Location').text()
        @$('input[name="image"]').val url
        @$('.image-upload-preview, .order-line-item-preview .item-image').html imagesTemplate images: [{ original: url }]

  selectedCurrencySource: -> @$currencySourceFields.filter(':checked').val()

  updateSubtotalMessage: ->
    if @selectedCurrencySource() is 'TWD'
      @$('.subtotal-message').empty()
    else if isNaN (price = @$priceField.val())
      @$('.subtotal-message').text "單價必須為數字"
    else
      @$('.subtotal-message').text "商品單價換算為台幣 #{@formatMoney price, convert: true} 元"

  orderChanged: ->
    newFXRate = @order.get 'exchange_rate'
    @model.set 'price', @formatMoney(@model.get('price') * newFXRate / @oldFXRate)

    # last step, cache the existing exchange rate
    @oldFXRate = @order.get 'exchange_rate'
    @setupCurrencyExchange()
    @render()

  formatMoney: (money, { convert, decimalPlace } = {}) ->
    convert ?= false; decimalPlace ?= 0

    money = @fx(money).from(@cs).to(@ct) if convert
    parseFloat acct.toFixed money, decimalPlace

  save: (e) ->
    e.preventDefault()

    if @type is 'product'
      @model.related().product.set
        title: @$('input[name="title"]').val()
        brand: @$('input[name="brand"]').val()
        urls: _.compact [@$('input[name="url"]').val()]
        images: _.reject [_.pick { original: @$('input[name="image"]').val() }, (v) -> v], (i) -> _.isEmpty(i)
        color: @$('input[name="color"]').val()
        size: @$('input[name="size"]').val()
        description: @$('textarea[name="description"]').val()

    twdPrice = @$priceField.val()
    twdPrice = @formatMoney(twdPrice, convert: true) unless @selectedCurrencySource() is 'TWD'
    # http://stackoverflow.com/questions/6535948/nested-models-in-backbone-js-how-to-approach
    @model.set
      type: @type
      price: parseFloat twdPrice
      quantity: parseInt @$('.form-order-line-item [name="quantity"]').val()
      notes: @$('.form-order-line-item [name="notes"]').val()

    @isCreated = true

    @$('.order-line-item').removeAttr 'data-state'

  destroy: ->
    # TODO: need confirmation
    @model.destroy()

  edit: -> @$('.order-line-item').attr 'data-state', 'editing'

  cancel: ->
    if @model.isNew() and not @isCreated
      @model.destroy()
    else
      @$('.order-line-item').removeAttr 'data-state'
      @render()
