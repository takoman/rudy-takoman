#
# Routes file that exports route handlers for ease of testing.
#

Q = require 'q'
Order = require '../../models/order.coffee'
OrderLineItems = require '../../collections/order_line_items.coffee'

@index = (req, res, next) ->
  return res.redirect '/login' unless (accessKey = req.query.access_key)

  order = new Order _id: req.params.id
  orderLineItems = new OrderLineItems()
  orderPromise = order.fetch data: access_key: accessKey
  orderLineItemsPromise = orderLineItems.fetch data: order_id: req.params.id

  Q .all [orderPromise, orderLineItemsPromise]
    .then ->
      res.locals.sd.ORDER = order.toJSON()
      res.locals.sd.ORDER_LINE_ITEMS = orderLineItems.toJSON()
      res.render 'index',
        order: order
        orderLineItems: orderLineItems
    .catch (error) ->
      next error?.body?.message or 'failed to fetch order and order line items'
    .done()
