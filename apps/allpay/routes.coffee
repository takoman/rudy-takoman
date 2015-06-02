_ = require 'underscore'
_s = require 'underscore.string'
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

  if data.CheckMacValue is allpay.genCheckMacValue _.omit data, 'CheckMacValue'
    # TODO: move the creation of the invoice payment to the model
    payment = new InvoicePayment
      external_id: data.TradeNo
      invoice: invoiceId
      #payment_account:  # TODO: create or fetch a payment account
      total: data.TradeAmt
      #result:
      #message:
      details:
        # NOTE: When later updating the payment, we have to be careful not to
        # erase the offline_payment_details data.
        offline_payment_details:
          merchant_id: data.MerchantID
          merchant_trade_no: data.MerchantTradeNo
          return_code: data.RtnCode
          return_message: data.RtnMsg
          trade_no: data.TradeNo
          trade_amount: data.TradeAmt
          payment_type: data.PaymentType
          trade_date: data.TradeDate
          check_mac_value: data.CheckMacValue
          expire_date: data.ExpireDate

    if _s.startsWith data.PaymentType, 'ATM'
      _.extend payment.get('details')?.offline_payment_details,
        bank_code: data.BankCode
        v_account: data.vAccount

    if _s.startsWith(data.PaymentType, 'CVS') or _s.startsWith(data.PaymentType, 'BARCODE')
      _.extend payment.get('details')?.offline_payment_details,
        payment_no: data.PaymentNo
        barcode_1: data.Barcode1
        barcode_2: data.Barcode2
        barcode_3: data.Barcode3

    payment.save()
      .then -> res.render 'offline_payment_redirected', invoiceId: invoiceId
      .fail -> next 'failed to create the invoice payment'
  else
    res.send 'invalid offline payment'
