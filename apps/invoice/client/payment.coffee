_ = require 'underscore'
Backbone = require 'backbone'
InvoiceLineItems = require '../../../collections/invoice_line_items.coffee'
OrderLineItem = require '../../../models/order_line_item.coffee'
Product = require '../../../models/product.coffee'
AllPayModalView = require '../../../components/allpay_modal/view.coffee'
moment = require 'moment'
template = -> require('../templates/payment.jade') arguments...

module.exports = class ShippingView extends Backbone.View
  events:
    'click .pay-invoice': 'payViaAllPay'

  payViaAllPay: ->
    data =
      MerchantID: '2000132'
      # TODO: how to encode/decode unique ID < 20 chars with BSON ID?
      MerchantTradeNo: "#{+moment()}"
      MerchantTradeDate: '2014/11/10 10:44:29'
      PaymentType: 'aio'
      TotalAmount: '3999'
      TradeDesc: '美國感恩節瘋狂購物'
      ItemName: '電視 x 20'
      ReturnURL: 'http://takoman.co'
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
