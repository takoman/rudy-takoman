_           = require 'underscore'
Q           = require 'q'
sinon       = require 'sinon'
Backbone    = require 'backbone'
rewire      = require 'rewire'
moment      = require 'moment'
FlakeId     = require 'flake-idgen'
intformat   = require 'biguint-format'
AllPay      = require 'allpay'
routes      = require '../routes'
{ APP_URL, ALLPAY_PLATFORM_ID, ALLPAY_AIO_HASH_KEY, ALLPAY_AIO_HASH_IV,
  ALLPAY_AIO_CHECKOUT_URL, ALLPAY_AIO_ORDER_QUERY_URL } = require '../../../config'

allpay = new AllPay
  merchantId: ALLPAY_PLATFORM_ID
  hashKey: ALLPAY_AIO_HASH_KEY
  hashIV: ALLPAY_AIO_HASH_IV
  aioCheckoutUrl: ALLPAY_AIO_CHECKOUT_URL
  aioOrderQueryUrl: ALLPAY_AIO_ORDER_QUERY_URL

describe 'Allpay routes', ->
  beforeEach ->
    sinon.stub Backbone, 'sync'
    @res = { render: sinon.stub(), redirect: sinon.stub(), send: sinon.stub(), locals: { sd: {} } }

  afterEach ->
    Backbone.sync.restore()

  describe '#paymentFormHtml', ->
    beforeEach ->
      tradeNo = intformat((new FlakeId().next()), 'hex')
      tradeDate = moment.utc().format('YYYY/MM/DD HH:mm:ss')
      @req = body:
        invoiceId: '0123456789'
        MerchantID: '2000132'
        MerchantTradeNo: tradeNo
        MerchantTradeDate: tradeDate
        PaymentType: 'aio'
        TotalAmount: 99800
        TradeDesc: '賣家名字的訂單'
        ItemName: '電視 x 3#音響 x 2'
        ChoosePayment: 'ALL'

      routes.paymentFormHtml @req, @res

    it 'sends the payment form html as the response', ->
      data = _.extend {}, _.omit(@req.body, 'invoiceId'), {
        PlatformID: ALLPAY_PLATFORM_ID
        IgnorePayment: 'Alipay#Tenpay#TopUpUsed'
        ReturnURL: "#{APP_URL}/invoices/0123456789/allpay-payment-callback"
        OrderResultURL: "#{APP_URL}/invoices/0123456789/allpay-online-payment-redirected"
        NeedExtraPaidInfo: 'Y'
        ClientRedirectURL: "#{APP_URL}/invoices/0123456789/allpay-offline-payment-redirected"
        ExpireDate: 7
      }
      @res.send.args[0][0].should.equal(
        allpay.createFormHtml _.extend data, CheckMacValue: allpay.genCheckMacValue(data))

  describe '#offlinePaymentRedirected', ->
    beforeEach ->
      @invoiceId = '1234'
      @atmData =
        BankCode: '808'
        ExpireDate: '2015/06/09'
        MerchantID: '2000132'
        MerchantTradeNo: '536c4b84de800000'
        PaymentType: 'ATM_ESUN'
        RtnCode: '2'
        RtnMsg: 'Get VirtualAccount Succeeded'
        TradeAmt: '512'
        TradeDate: '2015/06/02 06:11:45'
        TradeNo: '1506020611374268'
        vAccount: '1234506094744989'
      @atmData.CheckMacValue = allpay.genCheckMacValue @atmData

      @cvsBarcodeData =
        Barcode1: '0406096EA'
        Barcode2: '3451511744830531'
        Barcode3: '0602B4000000512'
        ExpireDate: '2015/06/09 09:15:17'
        MerchantID: '2000132'
        MerchantTradeNo: '536c758417400000'
        PaymentNo: ''
        PaymentType: 'BARCODE_BARCODE'
        RtnCode: '10100073'
        RtnMsg: 'Get CVS Code Succeeded.'
        TradeAmt: '512'
        TradeDate: '2015/06/02 09:15:17'
        TradeNo: '1506020915077085'
      @cvsBarcodeData.CheckMacValue = allpay.genCheckMacValue @cvsBarcodeData

    describe 'with correct CheckMacValue in the request', ->
      beforeEach ->
        Backbone.sync.restore()
        dfd = Q.defer()
        sinon.stub Backbone, 'sync', (-> dfd.promise)
        @thenSpy = sinon.spy dfd.promise, 'then'

      describe 'ATM payment', ->
        beforeEach (done) ->
          @req = { params: { id: @invoiceId }, body: @atmData }
          routes.offlinePaymentRedirected @req, @res
          done()

        it 'saves the offline invoice payment properly', ->
          Backbone.sync.args[0][1].attributes.should.eql
            external_id: @atmData.TradeNo
            invoice: @invoiceId
            total: @atmData.TradeAmt
            allpay_offline_payment_details:
              merchant_id: @atmData.MerchantID
              merchant_trade_no: @atmData.MerchantTradeNo
              return_code: @atmData.RtnCode
              return_message: @atmData.RtnMsg
              trade_no: @atmData.TradeNo
              trade_amount: @atmData.TradeAmt
              payment_type: @atmData.PaymentType
              trade_date: @atmData.TradeDate
              check_mac_value: @atmData.CheckMacValue
              expire_date: @atmData.ExpireDate
              bank_code: @atmData.BankCode
              v_account: @atmData.vAccount

        it 'renders the redirection template', ->
          @thenSpy.args[0][0]()
          @res.render.args[0][0].should.equal 'offline_payment_redirected'
          @res.render.args[0][1].should.eql invoiceId: @invoiceId

      _.each ['CVS', 'BARCODE'], (method) ->
        describe "#{method} payment", ->
          beforeEach (done) ->
            @req = { params: { id: @invoiceId }, body: @cvsBarcodeData }
            routes.offlinePaymentRedirected @req, @res
            done()

          it 'saves the offline invoice payment properly', ->
            Backbone.sync.args[0][1].attributes.should.eql
              external_id: @cvsBarcodeData.TradeNo
              invoice: @invoiceId
              total: @cvsBarcodeData.TradeAmt
              allpay_offline_payment_details:
                merchant_id: @cvsBarcodeData.MerchantID
                merchant_trade_no: @cvsBarcodeData.MerchantTradeNo
                return_code: @cvsBarcodeData.RtnCode
                return_message: @cvsBarcodeData.RtnMsg
                trade_no: @cvsBarcodeData.TradeNo
                trade_amount: @cvsBarcodeData.TradeAmt
                payment_type: @cvsBarcodeData.PaymentType
                trade_date: @cvsBarcodeData.TradeDate
                check_mac_value: @cvsBarcodeData.CheckMacValue
                expire_date: @cvsBarcodeData.ExpireDate
                payment_no: @cvsBarcodeData.PaymentNo
                barcode_1: @cvsBarcodeData.Barcode1
                barcode_2: @cvsBarcodeData.Barcode2
                barcode_3: @cvsBarcodeData.Barcode3

          it 'renders the redirection template', ->
            @thenSpy.args[0][0]()
            @res.render.args[0][0].should.equal 'offline_payment_redirected'
            @res.render.args[0][1].should.eql invoiceId: @invoiceId

    describe 'with incorrect CheckMacValue in the request', ->
      beforeEach ->
        @atmData.CheckMacValue = 'InVALiDCheCKMaCvaLuE'
        @req = { params: { id: @invoiceId }, body: @atmData }
        routes.offlinePaymentRedirected @req, @res

      it 'sends proper error message', ->
        @res.send.args[0][0].should.equal 'invalid offline payment (check mac value not match)'
