#
# Routes file that exports route handlers for ease of testing.
#

_ = require 'underscore'
Merchants = require '../../collections/merchants.coffee'
Order = require '../../models/order.coffee'
OrderLineItems = require '../../collections/order_line_items.coffee'
money = require '../../lib/money.js'
Q = require 'q'

@index = (req, res, next) ->
  return res.redirect '/login' unless req.user

  merchants = new Merchants()
  order = new Order(_id: req.params.id)
  orderLineItems = new OrderLineItems()
  merchants.fetch data: user_id: req.user.get('_id')
    .then ->
      return next('The logged in user is not a merchant') if merchants.length is 0

      Q.all [order.fetch(), orderLineItems.fetch(data: order_id: req.params.id)]
    .then ->
      res.locals.sd.ORDER = order.toJSON()
      res.locals.sd.ORDER_LINE_ITEMS = orderLineItems.toJSON()
      res.render 'index',
        merchant: merchants.at(0)
        order: order
        orderLineItems: orderLineItems
        currencies: money.CURRENCIES
    .catch (error) ->
      next error?.body?.message or 'failed to fetch order and order line items'
    .done()

@orderCreation = (req, res, next) ->
  # Redirect to /login if the user is not logged in
  return res.redirect '/login' unless req.user

  # Require the logged in user to be a merchant
  merchants = new Merchants()

  merchants.fetch data: user_id: req.user.get('_id')
    # NOTE: Server-side Backbone.sync uses backbone-super-sync, which returns
    # a Q promise that has slightly different interfaces than a jQuery one.
    # https://github.com/artsy/backbone-super-sync/blob/2e7eacbecf26982b9f57c94d8c7f79ac3dff8801/index.js#L89
    .then ->
      return next('The logged in user is not a merchant') if merchants.length is 0

      # When editing, the order and orderLineItems objects should be fetched
      # from the server before rendering.
      order = new Order(merchant: merchants.at(0).get('_id'))
      orderLineItems = new OrderLineItems()
      res.locals.sd.ORDER = order.toJSON()
      res.locals.sd.ORDER_LINE_ITEMS = orderLineItems.toJSON()
      res.render 'index',
        merchant: merchants.at(0)
        order: order
        orderLineItems: orderLineItems
        acct: acct
        currencies: money.CURRENCIES
    #.fail ->
    #  return next('Failed to fetch the merchant')
