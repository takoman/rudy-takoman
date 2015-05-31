Invoice = require '../../models/invoice.coffee'

@paymentConfirmation = (req, res, next) ->
  res.locals.sd.PAYMENT = req.body
  res.render 'confirmation'
