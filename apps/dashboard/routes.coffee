#
# Routes file that exports route handlers for ease of testing.
#

Merchants = require '../../collections/merchants.coffee'
Order = require '../../models/order.coffee'
OrderLineItems = require '../../collections/order_line_items.coffee'

@orderCreation = (req, res, next) ->
  # TODO In addition, we have to check if the user is a merchant.
  # If he/she is a regular user, 404.
  return res.redirect '/login' unless req.user

  merchants = new Merchants()
  merchants.fetch data: user_id: req.user.get('_id')
    .done ->
      return next("The logged in user is not a merchant") if merchants.length is 0

      # When editing, the order and orderLineItems objects should be fetched
      # from the server before rendering.
      order = new Order(merchant: merchants.at(0).get('_id'))
      orderLineItems = new OrderLineItems()
      res.locals.sd.ORDER = order.toJSON()
      res.locals.sd.ORDER_LINE_ITEMS = orderLineItems.toJSON()
      res.render 'order_creation', order: order, orderLineItems: orderLineItems
