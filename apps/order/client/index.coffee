_ = require 'underscore'
Backbone = require "backbone"
Order = require "../../../models/order.coffee"
OrderLineItem = require "../../../models/order_line_item.coffee"
OrderLineItems = require "../../../collections/order_line_items.coffee"
CurrentUser = require "../../../models/current_user.coffee"
OrderLineItemView = require './order_line_item_view.coffee'
acct = require 'accounting'
{ API_URL, ORDER, ORDER_LINE_ITEMS } = require('sharify').data

acct.settings.currency = _.defaults
  precision: 0
  symbol: 'NT'
  format: '%s %v'
, acct.settings.currency

module.exports.OrderFormView = class OrderFormView extends Backbone.View

  initialize: (options) ->
    { @order, @orderLineItems } = options
    @user = CurrentUser.orNull()

    @listenTo @order, 'change', @orderChanged
    @listenTo @orderLineItems, 'change add remove', @updateTotal

    @$currencySourceInput = @$ '#form-set-exchange-rate [name="currency-source"]'
    @$exchangeRateInput = @$ '#form-set-exchange-rate [name="exchange-rate"]'

    @initializeItems()

  events:
    'click #edit-exchange-rate': 'startEditingOrderExchangeRate'
    'submit #form-set-exchange-rate': 'setOrderExchangeRate'
    'click #edit-order-notes': 'startEditingOrderNotes'
    'submit #form-set-notes': 'setOrderNotes'
    'click .add-item': 'addItem'
    'click .save-order': 'saveOrderAndRelated'
    'change select#currency-source': 'toggleExchangeRateInput'

  initializeItems: ->
    @orderLineItems.each (item) =>
      itemView = new OrderLineItemView
        type: item.get('type')
        order: @order
        model: item
      @$('.panel-order-line-items .order-line-items').append itemView.el

  startEditingOrderExchangeRate: ->
    @$currencySourceInput.val(@order.get 'currency_source').trigger 'change'
    @$exchangeRateInput.val @order.get 'exchange_rate'
    @$('.panel-exchange-rate-settings').attr 'data-state', 'editing'

  toggleExchangeRateInput: ->
    $fxrate = @$('.form-group-exchange-rate')
    currencySource = @$currencySourceInput.val()
    if currencySource is 'TWD'
      $fxrate.hide()
      @$exchangeRateInput.val '1'
    else
      $fxrate.fadeIn().removeClass 'hidden'
      @$exchangeRateInput.val ''

  setOrderExchangeRate: (e) ->
    e.preventDefault()
    @order.set
      currency_source: @$currencySourceInput.val()
      exchange_rate: parseFloat @$exchangeRateInput.val()
    @$('.exchange-rate-results .currency-source').text @$('select#currency-source option:selected').text()
    @$('.exchange-rate-results .exchange-rate').text @order.get 'exchange_rate'
    @$('.panel-exchange-rate-settings').removeAttr 'data-state'
    @$('.panel-order-line-items').removeClass('panel-disabled').addClass 'panel-secondary'

  startEditingOrderNotes: ->
    @$('.order-partial.order-notes').attr 'data-state', 'editing'

  setOrderNotes: (e) ->
    e.preventDefault()
    notes = @$('.order-notes [name="notes"]').val()
    @order.set notes: notes
    @$('.order-notes .order-notes-preview').text notes
    @$('.order-notes').removeAttr 'data-state'

  updateTotal: ->
    types = ['product', 'shipping', 'commission']

    _.each types, (t) => @$("#order-#{t}-total").text acct.formatMoney @orderLineItems.total(t)
    @$('#order-total').text acct.formatMoney @orderLineItems.total()

  orderChanged: -> undefined

  addItem: (e) ->
    itemView = new OrderLineItemView
      type: $(e.currentTarget).data 'item-type'
      order: @order
      model: @orderLineItems.add new OrderLineItem()

    itemView.edit()
    @$('.panel-order-line-items .order-line-items').append itemView.el

  #
  # Create/Save the order and order line items and products if the item
  # is product type.
  #
  saveOrderAndRelated: ->
    @order.save()
      .then (data, textStatus, xhr) =>
        extraItemData = { order: @order.get('_id') }
        items = @orderLineItems.groupBy (i) -> if i.get('type') is 'product' then 'p' else 'np'

        # For all non-product items, just save them.
        $.when.apply($, _.map items.np, (i) -> i.save(extraItemData))
          .done -> console.log 'All non-product items have been saved'
          .fail -> console.log 'Some errors occured when saving non-product items'

        # For each of the product items, save the product first and save the
        # item with the product ID.
        # TODO: We can do smarter here. If the item isn't new (it has the
        # product ID already) and the product ID isn't changed, we could the
        # item and the product in parallel. But, anyway...
        saveProductItem = (item) ->
          item.related().product.save().then ->
            item.save _.extend({}, extraItemData, product: item.related().product.get('_id'))

        $.when.apply($, _.map items.p, (i) -> saveProductItem(i))
          .done -> console.log 'All product items saved'
          .fail -> console.log 'Some errors ocured when saving product items'

      .fail (xhr, textStatus, errorThrown) ->
        console.log 'Some error occured when saving the order'

module.exports.init = ->
  new OrderFormView
    el: $ "body"
    order: new Order ORDER
    orderLineItems: new OrderLineItems ORDER_LINE_ITEMS
