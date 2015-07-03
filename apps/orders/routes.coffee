_ = require 'underscore'
Merchants = require '../../collections/merchants.coffee'
Orders = require '../../collections/orders.coffee'
money = require '../../lib/money.js'
acct = require 'accounting'
Q = require 'q'

acct.settings.currency = _.defaults
  precision: 0
  symbol: 'NT'
  format: '%s %v'
, acct.settings.currency

@index = (req, res, next) ->
  return res.redirect '/login' unless req.user

  merchants = new Merchants()
  orders = new Orders()
  merchants.fetch data: user_id: req.user.get('_id')
    .then ->
      return next('The logged in user is not a merchant') if merchants.length is 0

      Q(orders.fetch(data: { merchant_id: merchants.at(0).get('_id'), sort: '-created_at' }))
    .then ->
      res.locals.sd.ORDERS = orders.toJSON()
      res.render 'index',
        merchant: merchants.at(0)
        orders: orders
        acct: acct
    .catch (error) ->
      next error?.body?.message or 'failed to fetch orders'
    .done()
