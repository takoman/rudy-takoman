_ = require 'underscore'
_s = require 'underscore.string'
Q = require 'q'
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

    @setupStickyActions()
    @initializeItems()
    @setupDirtyFormConfirmation()

    # TODO We have to refresh waypoints every time the vertical position of
    # the panel footer changes (almost every time the document height changes,
    # since the footer is at the bottom). Let's bind the refresh to the window
    # scroll event (but throttled) for now, and figure out a better way later.
    $(window).on 'scroll', _.throttle (-> Waypoint.refreshAll()), 150

  events:
    'click #edit-exchange-rate': 'startEditingOrderExchangeRate'
    'submit #form-set-exchange-rate': 'setOrderExchangeRate'
    'click #edit-order-notes': 'startEditingOrderNotes'
    'submit #form-set-notes': 'setOrderNotes'
    'click .add-item': 'addItem'
    'click .save-order': 'saveOrderAndRelated'
    'change select#currency-source': 'toggleExchangeRateInput'

  initializeItems: ->
    views = []
    @orderLineItems.each (item) =>
      itemView = new OrderLineItemView
        type: item.get('type')
        order: @order
        orderLineItems: @orderLineItems
        model: item
      views.push itemView.el
    @$('.panel-order-line-items .order-line-items').html views

  setupStickyActions: ->
    $actionsRow = @$('.panel-order-line-items .panel-footer')
    sticky = new Waypoint.Sticky
      element: $actionsRow[0]
      direction: 'up'
      offset: 'bottom-in-view'
      handler: -> $actionsRow.outerWidth @$wrapper.outerWidth()

    # Trigger the sticky row if it already goes beyond page bottom.
    pageBottom = $(window).scrollTop() + $(window).height()
    actionsRowBottom = $actionsRow.offset().top + $actionsRow.outerHeight()
    sticky.waypoint.trigger(['up']) if actionsRowBottom > pageBottom

  # Set up dirty form confirmation *only for* order line item forms.
  # TODO: Do all the forms and show better/more useful message.
  setupDirtyFormConfirmation: ->
    $(window).on 'beforeunload', =>
      if _.any _.map(@$('form.form-order-line-item'), (f) -> $(f).hasClass('dirty'))
        return '修改尚未儲存，您確定要離開嗎？'

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
    types = ['product', 'shipping', 'commission', 'tax']

    _.each types, (t) => @$("#order-#{t}-total").text acct.formatMoney @orderLineItems.total(t)
    @$('#order-total').text acct.formatMoney @orderLineItems.total()

    #for update tax
    @order.trigger 'totalChanged'
  orderChanged: -> undefined

  addItem: (e) ->
    itemView = new OrderLineItemView
      type: $(e.currentTarget).data 'item-type'
      order: @order
      orderLineItems: @orderLineItems
      model: @orderLineItems.add new OrderLineItem()

    itemView.edit()
    @$('.panel-order-line-items .order-line-items').append itemView.el

  #
  # Create/Save the order and order line items and products if the item
  # is product type.
  #
  saveOrderAndRelated: ->
    items = @orderLineItems.groupBy (i) -> if i.get('type') is 'product' then 'p' else 'np'

    saveNonProductItems = =>
      extraData = { order: @order.get('_id') }
      Q.all( _.map items.np, (item) -> item.save(extraData) )

    saveProductItems = =>
      extraData = { order: @order.get('_id') }
      Q.all( _.map items.p, (item) ->
        Q(item.related().product.save()).then ->
          Q(item.save _.extend({}, extraData, product: item.related().product.get('_id')))
      )

    # Create a fork in the control flow, where the fulfillment of orderPromise
    # will kick off two parallel and independent jobs to resolve
    # nonProductItemsPromise and productItemsPromise
    orderPromise = Q @order.save()
    nonProductItemsPromise = orderPromise.then saveNonProductItems
    productItemsPromise = orderPromise.then saveProductItems

    Q.all([orderPromise, nonProductItemsPromise, productItemsPromise])
      .then ->
        @$('.order-edit-message').text('訂單儲存成功！').addClass('alert-success').fadeIn()
      .catch (error) ->
        error = _s.capitalize error.responseJSON.message, true
        @$('.order-edit-message')
          .text("訂單儲存失敗 (#{error})。請再試一次或聯絡我們。")
          .addClass('alert-danger').fadeIn()
      .done -> $(window).scrollTop(0)

module.exports.init = ->
  new OrderFormView
    el: $ "body"
    order: new Order ORDER
    orderLineItems: new OrderLineItems ORDER_LINE_ITEMS
