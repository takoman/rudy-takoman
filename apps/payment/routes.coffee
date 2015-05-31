@offlinePaymentRedirected = (req, res, next) ->
  console.log req.body
  # Check the CheckMacValue
  # Create the payment record
  res.send '付款儲存中...'

@paymentConfirmation = (req, res, next) ->
  res.locals.sd.PAYMENT = req.body
  res.render 'confirmation'
