_ = require 'underscore'
AllPay = require 'allpay'
{ APP_URL, ALLPAY_PLATFORM_ID, ALLPAY_AIO_HASH_KEY, ALLPAY_AIO_HASH_IV } = require '../../config'

@paymentFormHtml = (req, res, next) ->
  allpay = new AllPay
    merchantId: ALLPAY_PLATFORM_ID
    hashKey: ALLPAY_AIO_HASH_KEY
    hashIV: ALLPAY_AIO_HASH_IV

  data = req.body
  invoiceId = data.invoiceId
  delete data.invoiceId
  data = _.extend data,
    # General settings
    PlatformID: ALLPAY_PLATFORM_ID
    IgnorePayment: 'Alipay#Tenpay#TopUpUsed'
    ReturnURL: "#{APP_URL}/invoices/#{invoiceId}/payment-callback"  # Payment completion callback
    OrderResultURL: "#{APP_URL}/invoices/#{invoiceId}/online-payment-redirected"  # Allpay tries to redirect here with data after an online payment completion.
    NeedExtraPaidInfo: 'Y'

    # Offline payment (ATM/CVS/BARCODE) settings
    #PaymentInfoURL: ""  # Offline payment creation callback
    ClientRedirectURL: "#{APP_URL}/invoices/#{invoiceId}/offline-payment-redirected"  # Allpay redirects here with data after creating an offline payment.

    # ATM settings
    ExpireDate: 7

    # CVS/BARCODE settings
    #StoreExpireDate: ''
    #Desc_1: ''
    #Desc_2: ''
    #Desc_3: ''
    #Desc_4: ''

  html = allpay.createFormHtml _.extend data, CheckMacValue: allpay.genCheckMacValue(data)

  res.send html
