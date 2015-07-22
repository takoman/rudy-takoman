_ = require 'underscore'
_s = require 'underscore.string'
Q = require 'q'
Backbone = require "backbone"
Order = require "../../../models/order.coffee"
OrderLineItem = require "../../../models/order_line_item.coffee"
OrderLineItems = require "../../../collections/order_line_items.coffee"
CurrentUser = require "../../../models/current_user.coffee"
Invoice = require "../../../models/invoice.coffee"
InvoiceLineItems = require "../../../collections/invoice_line_items.coffee"
InvoicePayment = require "../../../models/invoice_payment.coffee"
acct = require 'accounting'
totalTemplate = -> require("../../invoice/templates/invoice_total_summary.jade") arguments...
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
    @renderInvoiceTotalSummary()
    @renderMerchantInfo()
    @renderInvoiceLineItems()

  renderCustomerSummary: ->

  renderInvoiceTotalSummary: ->
    invoiceLineItems = new InvoiceLineItems()
    Q(invoiceLineItems.fetch(data: invoice_id: @invoice.get('_id')))
      .then ->
        @$('.panel-invoice-total .panel-content').html(
          totalTemplate invoiceLineItems: invoiceLineItems, acct: acct
        )
      .catch (error) -> console.log error
      .done()

  renderMerchantInfo: ->

  renderInvoiceLineItems: ->

module.exports.init = ->
  new PaymentConfirmationView
    el: $ "body"
    invoice: new Invoice INVOICE
    invoicePayment: new InvoicePayment INVOICE_PAYMENT
