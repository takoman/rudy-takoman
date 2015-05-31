_ = require 'underscore'
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

  initialize: ({ el, invoice, invoiceLineItems }) ->
    @invoice = invoice
    @invoiceLineItems = invoiceLineItems
    @render()

  render: ->
    @$el.html template
      _: _
      invoice: @invoice
      invoiceLineItems: @invoiceLineItems

    @renderInvoiceLineItems()

  renderInvoiceLineItems: ->
    @invoiceLineItems.each (invoiceLineItem) ->
      oli = invoiceLineItem.get('order_line_item')
      product = new Product(id: oli.product) if oli.product?
      product?.fetch()  # When the item is not a product, this will be undefined.
        .done((data, textStatus, xhr) ->
          $ili = $("[data-invoice-line-item-id='#{invoiceLineItem.get('_id')}']")
          $ili.find('.invoice-line-item-image').html "<img src='#{product.get('images')?[0]?.original}'>"
          $ili.find('.invoice-line-item-brand').text "#{product.get('brand')}"
          $ili.find('.invoice-line-item-title').text "#{product.get('title')}"
        ).fail((xhr, textStatus, error) -> undefined)
