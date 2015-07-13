_ = require 'underscore'
Q = require 'q'
AllPay = require 'allpay'
InvoicePayment = require '../../models/invoice_payment.coffee'
{ APP_URL, ALLPAY_PLATFORM_ID, ALLPAY_AIO_HASH_KEY, ALLPAY_AIO_HASH_IV,
  ALLPAY_AIO_CHECKOUT_URL, ALLPAY_AIO_ORDER_QUERY_URL } = require '../../config'

allpay = new AllPay
  merchantId: ALLPAY_PLATFORM_ID
  hashKey: ALLPAY_AIO_HASH_KEY
  hashIV: ALLPAY_AIO_HASH_IV
  aioCheckoutUrl: ALLPAY_AIO_CHECKOUT_URL
  aioOrderQueryUrl: ALLPAY_AIO_ORDER_QUERY_URL

@paymentFormHtml = (req, res, next) ->
  data = req.body
  invoiceId = data.invoiceId
  data = _.extend {}, _.omit(data, 'invoiceId'),
    # General settings
    PlatformID: ALLPAY_PLATFORM_ID
    IgnorePayment: 'Alipay#Tenpay#TopUpUsed'
    ReturnURL: "#{APP_URL}/invoices/#{invoiceId}/allpay-payment-callback"  # Payment completion callback
    OrderResultURL: "#{APP_URL}/invoices/#{invoiceId}/allpay-online-payment-redirected"  # Allpay tries to redirect here with data after an online payment completion.
    NeedExtraPaidInfo: 'Y'

    # Offline payment (ATM/CVS/BARCODE) settings
    #PaymentInfoURL: ""  # Offline payment creation callback
    ClientRedirectURL: "#{APP_URL}/invoices/#{invoiceId}/allpay-offline-payment-redirected"  # Allpay redirects here with data after creating an offline payment.

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

@offlinePaymentRedirected = (req, res, next) ->
  invoiceId = req.params.id
  data = req.body

  if data.CheckMacValue isnt allpay.genCheckMacValue _.omit data, 'CheckMacValue'
    return res.send 'invalid offline payment (check mac value not match)'

  payment = new InvoicePayment()
  payment.setAllPayOfflinePaymentData invoiceId, data

  Q(payment.save())
    .then -> res.render 'offline_payment_redirected', invoiceId: invoiceId
    .catch -> next 'failed to create the invoice payment'
    .done()
