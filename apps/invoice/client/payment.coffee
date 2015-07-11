_ = require 'underscore'
Q = require 'q'
acct = require 'accounting'
Backbone = require 'backbone'
moment = require 'moment'
FlakeId = require 'flake-idgen'
intformat = require 'biguint-format'
InvoiceLineItems = require '../../../collections/invoice_line_items.coffee'
OrderLineItems = require '../../../collections/order_line_items.coffee'
OrderLineItem = require '../../../models/order_line_item.coffee'
Product = require '../../../models/product.coffee'
AllPayModalView = require '../../../components/allpay_modal/view.coffee'
template = -> require('../templates/payment.jade') arguments...

module.exports = class PaymentView extends Backbone.View
  events:
    'click .pay-invoice': 'payViaAllPay'

  initialize: (options) ->
    { @merchant, @invoice, @invoiceLineItems } = options
    @render()
    @fetchAndRenderProducts()

  render: ->
    @$el.html template
      _: _
      acct: acct
      invoice: @invoice
      invoiceLineItems: @invoiceLineItems

  payViaAllPay: ->
    merchantTradeNo = intformat((new FlakeId().next()), 'hex')
    data =
      invoiceId: @invoice.get('_id')
      MerchantID: '2000132' # TODO: use the actual merchant ID
      MerchantTradeNo: merchantTradeNo
      MerchantTradeDate: moment.utc().format('YYYY/MM/DD HH:mm:ss')
      PaymentType: 'aio'
      # Maybe we should move the total calculation to the server side?
      TotalAmount: @invoiceLineItems.total()
      TradeDesc: "#{@merchant.get('merchant_name')}訂單 (#{merchantTradeNo})"
      ItemName: @invoiceLineItems.allpayItemName()
      ChoosePayment: 'ALL'

    new AllPayModalView(data: data).startPayment()

  fetchAndRenderProducts: ->
    promises = []
    @invoiceLineItems.each (ili) ->
      oli = ili.related().order_line_item
      if oli.isProduct()
        promises.push Q(oli.related().product.fetch()).then ->
          product = oli.related().product
          $ili = $("[data-invoice-line-item-id='#{ili.get('_id')}']")
          $ili.find('.invoice-line-item-image').html "<img src='#{product.get('images')?[0]?.original}'>"
          $ili.find('.invoice-line-item-brand').text "#{product.get('brand')}"
          $ili.find('.invoice-line-item-title').text "#{product.get('title')}"
          product

    Q.all(promises)
      .then (results) -> @$('button.pay-invoice').removeClass('btn-disabled').removeAttr 'disabled'
      .catch (error) -> undefined
      .done()
