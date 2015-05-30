_ = require 'underscore'
AllPay = require 'allpay'
{ ALLPAY_PLATFORM_ID, ALLPAY_AIO_HASH_KEY, ALLPAY_AIO_HASH_IV } = require '../../config'

@paymentFormHtml = (req, res, next) ->
  allpay = new AllPay
    merchantId: ALLPAY_PLATFORM_ID
    hashKey: ALLPAY_AIO_HASH_KEY
    hashIV: ALLPAY_AIO_HASH_IV

  data = req.body
  data = _.extend data, PlatformID: ALLPAY_PLATFORM_ID
  html = allpay.createFormHtml _.extend data, CheckMacValue: allpay.genCheckMacValue(data)

  res.send html
