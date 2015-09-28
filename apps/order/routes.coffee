#
# Routes file that exports route handlers for ease of testing.
#

_ = require 'underscore'
Merchants = require '../../collections/merchants.coffee'
Order = require '../../models/order.coffee'
OrderLineItems = require '../../collections/order_line_items.coffee'
money = require '../../lib/money.js'
acct = require 'accounting'
Q = require 'q'
{ API_URL } = require('sharify').data

@index = (req, res, next) ->
  # TODO: Temporarily pass on to the /orders/:id?access_key=xxx route to
  # handle anonymous access with an access token
  # return res.redirect '/login' unless (user = req.user)
  return next() unless (user = req.user)

  order = new Order _id: req.params.id
  orderLineItems = new OrderLineItems()
  merchants = new Merchants()
  merchants.fetch data: user_id: req.user.get('_id')
    .then ->
      return next('The logged in user is not a merchant') if merchants.length is 0

      order.urlRoot = -> "#{API_URL}/api/v2/orders"
      Q.all [
        order.fetch(data: access_token: user.get 'accessToken'),
        orderLineItems.fetch(data: order_id: req.params.id)
      ]
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
  Q(merchants.fetch data: user_id: req.user.get('_id'))
    .then ->
      return next('The logged in user is not a merchant') if merchants.length is 0

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
    .catch (error) ->
      next error?.body?.message or 'failed to fetch merchant or order'
    .done()
