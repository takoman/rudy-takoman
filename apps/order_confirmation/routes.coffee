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
  return res.redirect '/login' unless (accessKey = req.query.access_key)

  order = new Order _id: req.params.id
  orderLineItems = new OrderLineItems()
  Q.all [
    order.fetch(data: access_key: accessKey),
    orderLineItems.fetch(data: order_id: req.params.id)
  ]
    .then ->
      res.locals.sd.ORDER = order.toJSON()
      res.locals.sd.ORDER_LINE_ITEMS = orderLineItems.toJSON()
      res.render 'index',
        order: order
        orderLineItems: orderLineItems
        currencies: money.CURRENCIES
    .catch (error) ->
      next error?.body?.message or 'failed to fetch order and order line items'
    .done()
