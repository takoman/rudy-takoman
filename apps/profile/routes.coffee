_ = require 'underscore'
Merchant = require '../../models/merchant.coffee'
Q = require 'q'

@index = (req, res, next) ->
  merchant = new Merchant(_id: req.params.id)
  Q(merchant.fetch())
    .then ->
      res.render 'index',
        merchant: merchant
    .catch (error) ->
      next error?.body?.message or 'failed to fetch merchant'
    .done()
