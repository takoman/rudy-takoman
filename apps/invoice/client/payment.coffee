_ = require 'underscore'
Q = require 'q'
acct = require 'accounting'
Backbone = require 'backbone'
moment = require 'moment'
FlakeId = require 'flake-idgen'
intformat = require 'biguint-format'
InvoiceLineItems = require '../../../collections/invoice_line_items.coffee'
OrderLineItem = require '../../../models/order_line_item.coffee'
Product = require '../../../models/product.coffee'
AllPayModalView = require '../../../components/allpay_modal/view.coffee'
template = -> require('../templates/payment.jade') arguments...

module.exports = class ShippingView extends Backbone.View
  events:
    'click .pay-invoice': 'payViaAllPay'

  payViaAllPay: ->
    data =
      invoiceId: @invoice.get('_id')
      MerchantID: '2000132' # TODO: use the actual merchant ID
      MerchantTradeNo: intformat((new FlakeId().next()), 'hex')
      MerchantTradeDate: moment.utc().format('YYYY/MM/DD HH:mm:ss')
      PaymentType: 'aio'
      # Maybe we should move the total calculation to the server side?
      TotalAmount: @invoiceLineItems.total()
      TradeDesc: '賣家名字的訂單' # TODO: figure out a descriptive name
      ItemName: @invoiceLineItems.allpayItemName()
      ChoosePayment: 'ALL'

    new AllPayModalView(el: $('<div></div>').appendTo('body'), data: data).startPayment()

  initialize: (options) ->
    { @merchant, @invoice, @invoiceLineItems } = options
    @render()

  render: ->
    @$el.html template
      _: _
      acct: acct
      invoice: @invoice
      invoiceLineItems: @invoiceLineItems

    @renderInvoiceLineItems()

  # TODO: This is identical to the one in shipping. We should DRY this up.
  renderInvoiceLineItems: ->
    @invoiceLineItems.each (invoiceLineItem) ->
      oli = invoiceLineItem.get('order_line_item')
      product = new Product(_id: oli.product) if oli.product?
      Q(product?.fetch())  # When the item is not a product, this will be undefined.
        .then ->
          $ili = $("[data-invoice-line-item-id='#{invoiceLineItem.get('_id')}']")
          $ili.find('.invoice-line-item-image').html "<img src='#{product.get('images')?[0]?.original}'>"
          $ili.find('.invoice-line-item-brand').text "#{product.get('brand')}"
          $ili.find('.invoice-line-item-title').text "#{product.get('title')}"
        .catch -> undefined
        .done()
