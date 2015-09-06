#
# Routes file that exports route handlers for ease of testing.
#
_ = require 'underscore'
Merchants = require '../../collections/merchants.coffee'
Merchant = require '../../models/merchant.coffee'
Q = require 'q'

@profile = (req, res, next) ->
  return res.redirect '/login' unless req.user

  merchants = new Merchants()
  merchants.fetch data: user_id: req.user.get('_id')
    .then ->
      return next('The logged in user is not a merchant') if merchants.length is 0
    .then ->
      res.render 'profile',
        merchant: merchants.at(0)
    .catch (error) ->
      next error?.body?.message or 'failed to fetch order and order line items'
    .done()
