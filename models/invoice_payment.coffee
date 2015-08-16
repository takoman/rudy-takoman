_ = require 'underscore'
_s = require 'underscore.string'
Backbone = require 'backbone'
SantaModel = require './mixins/santa_model.coffee'
{ API_URL, APP_URL } = require('sharify').data

module.exports = class InvoicePayment extends Backbone.Model

  _.extend @prototype, SantaModel

  urlRoot: "#{API_URL}/api/v1/invoice_payments"

  setAllPayOfflinePaymentData: (invoiceId, allPayData = {}) ->
    invoicePaymentData =
      external_id: allPayData.TradeNo
      invoice: invoiceId
      # payment_account:  # TODO: create or fetch a payment account for the customer
      total: allPayData.TradeAmt
      result: @parseAllPayOfflinePaymentReturnCode allPayData.RtnCode
      message: allPayData.RtnMsg
      allpay_offline_payment_details:
        merchant_id: allPayData.MerchantID
        merchant_trade_no: allPayData.MerchantTradeNo
        return_code: allPayData.RtnCode
        return_message: allPayData.RtnMsg
        trade_no: allPayData.TradeNo
        trade_amount: allPayData.TradeAmt
        payment_type: allPayData.PaymentType
        trade_date: allPayData.TradeDate
        expire_date: allPayData.ExpireDate
        raw: allPayData

    if _s.startsWith(allPayData.PaymentType, 'ATM')
      _.extend invoicePaymentData.allpay_offline_payment_details,
        bank_code: allPayData.BankCode
        v_account: allPayData.vAccount

    if _s.startsWith(allPayData.PaymentType, 'CVS') or _s.startsWith(allPayData.PaymentType, 'BARCODE')
      _.extend invoicePaymentData.allpay_offline_payment_details,
        payment_no: allPayData.PaymentNo
        barcode_1: allPayData.Barcode1
        barcode_2: allPayData.Barcode2
        barcode_3: allPayData.Barcode3

    @set _.pick(invoicePaymentData, (v) -> v?)

  setAllPayPaymentData: (invoiceId, allPayData = {}) ->
    invoicePaymentData =
      external_id: allPayData.TradeNo
      invoice: invoiceId
      # payment_account:  # TODO: create or fetch a payment account for the customer
      total: allPayData.TradeAmt
      result: @parseAllPayPaymentReturnCode allPayData.RtnCode
      message: allPayData.RtnMsg
      details:
        merchant_id: allPayData.MerchantID
        merchant_trade_no: allPayData.MerchantTradeNo
        return_code: allPayData.RtnCode
        return_message: allPayData.RtnMsg
        trade_no: allPayData.TradeNo
        trade_amount: allPayData.TradeAmt
        payment_date: allPayData.PaymentDate
        payment_type: allPayData.PaymentType
        payment_type_charge_fee: allPayData.PaymentTypeChargeFee
        trade_date: allPayData.TradeDate
        simulate_paid: allPayData.SimulatePaid
        raw: allPayData

    @set _.pick(invoicePaymentData, (v) -> v?)

  # Success if code is 1 or 800 (貨到付款訂單建立成功)
  parseAllPayPaymentReturnCode: (code) ->
    if code is '1' or code is '800' then 'success' else 'failure'

  # Success if code is 2 (ATM) or 10100073 (CVS/BARCODE)
  parseAllPayOfflinePaymentReturnCode: (code) ->
    if code is '2' or code is '10100073' then 'success' else 'failure'

  isOffline: -> @get('allpay_offline_payment_details')?

  # AKA AllPay Offline Payment Details
  aopd: -> @get('allpay_offline_payment_details') or {}

  paymentType: -> @aopd()['payment_type']?.split('_')[0]

  paymentTypeLabel: ->
    if @paymentType() is 'ATM'
      'ATM'
    else if @paymentType() is 'CVS'
      '超商代碼'
    else if @paymentType() is 'BARCODE'
      '超商條碼'
    else
      ''
