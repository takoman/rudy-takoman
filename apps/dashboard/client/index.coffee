_ = require 'underscore'
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
    'click .add-item': 'addItem'
    'click .save-order': 'saveOrderAndRelated'
    'change select#currency-source': 'toggleExchangeRateInput'

  startEditingOrderExchangeRate: ->
    @$('.panel-exchange-rate-settings').attr 'data-state', 'editing'

  toggleExchangeRateInput: ->
    $fxrate = @$('.form-group-exchange-rate')
    currencySource = @$('#form-set-exchange-rate [name="currency-source"]').val()
    if currencySource is 'TWD'
      $fxrate.hide()
      $fxrate.find('[name="exchange-rate"]').val '1'
    else
      $fxrate.fadeIn().removeClass 'hidden'
      $fxrate.find('[name="exchange-rate"]').val ''

  setOrderExchangeRate: (e) ->
    e.preventDefault()
    @order.set
      currency_source: @$('select#currency-source').val()
      exchange_rate: @$('input#exchange-rate').val()
    @$('.exchange-rate-results .currency-source').text @$('select#currency-source option:selected').text()
    @$('.exchange-rate-results .exchange-rate').text @order.get 'exchange_rate'
    @$('.panel-exchange-rate-settings').removeAttr 'data-state'
    @$('.panel-order-line-items').removeClass('panel-disabled').addClass 'panel-secondary'

  updateTotal: ->
    types = ['product', 'shipping', 'commission']
    itemsByType = _.pick @orderLineItems.groupBy('type'), types

    # We can move the calculation to the OrderLineItems collection model.
    subtotalByType = _.mapObject itemsByType, (items, type) ->
      _.reduce items, ((m, i) -> m + i.get('quantity') * i.get('price')), 0

    _.each types, (t) => @$("#order-#{t}-total").text(subtotalByType[t] or 0)
    @$('#order-total').text _.reduce subtotalByType, ((m, t) -> m + t), 0

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
      .done (data, textStatus, xhr) =>
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

        # The loop approach would look like this...
        # @orderLineItems.each (item) =>
        #   itemData = { order: @order.get('_id') }
        #   if item.get('type') is 'product'
        #     item.related().product.save()
        #       .done (data, textStatus, xhr) ->
        #         item.save _.extend itemData, product: item.related().product.get('_id')
        #   else
        #     item.save(itemData)
      .fail (xhr, textStatus, errorThrown) ->
        console.log 'Some error occured when saving the order'

module.exports.init = ->
  new OrderFormView
    el: $ "body"
    order: new Order ORDER
    orderLineItems: new OrderLineItems ORDER_LINE_ITEMS
