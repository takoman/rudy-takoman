_ = require 'underscore'
_s = require 'underscore.string'
Q = require 'q'
Backbone = require "backbone"
Merchant = require "../../../models/merchant.coffee"
Order = require "../../../models/order.coffee"
OrderLineItem = require "../../../models/order_line_item.coffee"
OrderLineItems = require "../../../collections/order_line_items.coffee"
CurrentUser = require "../../../models/current_user.coffee"
Invoice = require "../../../models/invoice.coffee"
InvoiceLineItems = require "../../../collections/invoice_line_items.coffee"
InvoicePayment = require "../../../models/invoice_payment.coffee"
acct = require 'accounting'
totalTemplate = -> require("../../invoice/templates/invoice_total_summary.jade") arguments...
invoiceLineItemTemplate = -> require("../templates/invoice_line_item_row.jade") arguments...
{ API_URL, INVOICE, INVOICE_PAYMENT } = require('sharify').data

acct.settings.currency = _.defaults
  precision: 0
  symbol: 'NT'
  format: '%s %v'
, acct.settings.currency

module.exports.PaymentConfirmationView = class PaymentConfirmationView extends Backbone.View
  initialize: (options) ->
    { @invoice, @invoicePayment } = options
    @render()

  render: ->
    @renderCustomerSummary()
    @renderInvoiceLineItemsAndTotal()
    @renderMerchantInfo()

  renderCustomerSummary: ->
    @order = new Order @invoice.get('order')
    @customer = @order.related().customer
    Q.all([Q(@order.fetch()), Q(@customer.fetch())])
      .then =>
        @$('.panel-order-customer .customer-name').text @customer.get 'name'
        @$('.panel-order-customer .customer-address').text @order.shippingAddress()
        @$('.panel-order-customer .customer-phone').text @customer.get 'phone'
        @$('.panel-order-customer .customer-email').text @customer.get 'email'
      .catch (error) -> console.log error
      .done()

  renderInvoiceLineItemsAndTotal: ->
    @invoiceLineItems = new InvoiceLineItems()
    Q(@invoiceLineItems.fetch(data: invoice_id: @invoice.get('_id')))
      .then =>
        @$('.panel-invoice-total .panel-content').html totalTemplate invoiceLineItems: @invoiceLineItems, acct: acct
        @invoiceLineItems.each (ili) ->
          @$('.invoice-line-items-table tbody').append invoiceLineItemTemplate invoiceLineItem: ili, acct: acct
          oli = ili.related().order_line_item
          return unless oli.isProduct()
          (product = oli.related().product).fetch().then ->
            $ili = $(".invoice-line-items-table [data-invoice-line-item-id='#{ili.get('_id')}']")
            $ili.find('.invoice-line-item-image').html "<img src='#{product.get('images')?[0]?.original}'>"
            $ili.find('.invoice-line-item-brand').text "#{product.get('brand')}"
            $ili.find('.invoice-line-item-title').text "#{product.get('title')}"
      .catch (error) -> console.log error
      .done()

  renderMerchantInfo: ->
    @merchant = @order.related().merchant
    Q(@merchant.fetch())
      .then =>
        @$('.panel-order-merchant .merchant-source-countries').text @merchant.get('source_countries').join(", ")
        @$('.panel-order-merchant .merchant-name').text @merchant.get('merchant_name')
      .catch (error) -> console.log error
      .done()

module.exports.init = ->
  new PaymentConfirmationView
    el: $ "body"
    invoice: new Invoice INVOICE
    invoicePayment: new InvoicePayment INVOICE_PAYMENT
