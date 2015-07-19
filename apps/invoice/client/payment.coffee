_ = require 'underscore'
Q = require 'q'
acct = require 'accounting'
Backbone = require 'backbone'
moment = require 'moment'
FlakeId = require 'flake-idgen'
intformat = require 'biguint-format'
PaymentAccounts = require '../../../collections/payment_accounts.coffee'
InvoiceLineItems = require '../../../collections/invoice_line_items.coffee'
Order = require '../../../models/order.coffee'
OrderLineItems = require '../../../collections/order_line_items.coffee'
OrderLineItem = require '../../../models/order_line_item.coffee'
Product = require '../../../models/product.coffee'
AllPayModalView = require '../../../components/allpay_modal/view.coffee'
template = -> require('../templates/payment.jade') arguments...

module.exports = class PaymentView extends Backbone.View
  events:
    'click .pay-invoice': 'payViaAllPay'
    'click .edit-contact-and-shipping': 'editShipping'

  initialize: (options) ->
    { @merchant, @invoice, @invoiceLineItems } = options
    @render()
    @preparePaymentAndRenderProduct()

  render: ->
    @$el.html template
      _: _
      acct: acct
      invoice: @invoice
      invoiceLineItems: @invoiceLineItems

    @fetchAndRenderCustomerInfo()

  fetchAndRenderCustomerInfo: ->
    @order = new Order @invoice.get('order')
    @customer = @order.related().customer
    Q.all([Q(@order.fetch()), Q(@customer.fetch())])
      .then =>
        @$('.customer-name').text @customer.get 'name'
        @$('.customer-address').text @order.shippingAddress()
        @$('.customer-phone').text @customer.get 'phone'
        @$('.customer-email').text @customer.get 'email'
      .catch -> console.log 'fetch order or customer failed'
      .done()

  editShipping: ->
    Backbone.history.navigate "/invoices/#{@invoice.get '_id'}/shipping", trigger: true

  payViaAllPay: ->
    merchantTradeNo = intformat((new FlakeId().next()), 'hex')
    data =
      invoiceId: @invoice.get '_id'
      MerchantID: @merchantAccount.get 'external_id'
      MerchantTradeNo: merchantTradeNo
      MerchantTradeDate: moment.utc().format('YYYY/MM/DD HH:mm:ss')
      PaymentType: 'aio'
      # TODO: Maybe we should move the total calculation to the server side?
      TotalAmount: @invoiceLineItems.total()
      TradeDesc: "#{@merchant.get('merchant_name')}訂單 (#{merchantTradeNo})"
      ItemName: @invoiceLineItems.allpayItemName()
      ChoosePayment: 'ALL'

    new AllPayModalView(data: data).startPayment()

  #
  # Fetch necessary data for submitting payment to AllPay, render products
  # details, and enable the "pay" button.
  #
  preparePaymentAndRenderProduct: ->
    # TODO: Maybe we should move the account fetching to the server side?
    paymentAccounts = new PaymentAccounts()
    promises = [
      Q(paymentAccounts.fetch(data: merchant_id: @merchant.get('_id')))
        .then =>
          throw new Error('no payment account associated with this merchant') if paymentAccounts.length is 0
          @merchantAccount = paymentAccounts.at(0)
    ]
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
      .catch (error) -> console.log error
      .done()
