_ = require 'underscore'
Backbone = require 'backbone'
InvoiceLineItems = require '../../../collections/invoice_line_items.coffee'
OrderLineItem = require '../../../models/order_line_item.coffee'
Product = require '../../../models/product.coffee'
template = -> require('../templates/payment.jade') arguments...

module.exports = class ShippingView extends Backbone.View
  events:
    'click .pay-invoice': 'payViaAllPay'

  payViaAllPay: ->
    $placeholder = @$ '.payment-form-placeholder'
    data =
      MerchantID: '1057673'
      MerchantTradeNo: '1234567890'
      MerchantTradeDate: '2014/11/10 10:44:29'
      PaymentType: 'aio'
      TotalAmount: '3999'
      TradeDesc: '美國感恩節瘋狂購物'
      ItemName: '電視 x 20'
      ReturnURL: 'http://takoman.co'
      ChoosePayment: 'ALL'

    $.ajax
      url: '/allpay-payment-form-html'
      type: 'GET'
      data: data
      success: (html) ->
        $placeholder
          .html(html)
          .find('form').attr('target', 'allpay-window')
          .submit()

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
