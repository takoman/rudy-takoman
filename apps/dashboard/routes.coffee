#
# Routes file that exports route handlers for ease of testing.
#

Order = require '../../models/order.coffee'
OrderLineItems = require '../../collections/order_line_items.coffee'

@orderCreation = (req, res, next) ->
  # TODO In addition, we have to check if the user is a merchant.
  # If he/she is a regular user, 404.
  return res.redirect '/login' unless req.user

  # When editing, the order and orderLineItems objects should be fetched
  # from the server before rendering.
  order = new Order()
  orderLineItems = new OrderLineItems()
  res.locals.sd.ORDER = order.toJSON()
  res.locals.sd.ORDER_LINE_ITEMS = orderLineItems.toJSON()
  res.render 'order_creation', order: order, orderLineItems: orderLineItems
