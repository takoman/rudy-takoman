_ = require 'underscore'
_s = require 'underscore.string'
Q = require 'q'
Backbone = require "backbone"
Orders = require "../../../collections/orders.coffee"
Invoices = require "../../../collections/invoices.coffee"
ModalDialog = require "../../../components/modal_dialog/view.coffee"
{ API_URL, ORDERS } = require('sharify').data
orderConfirmationLinkTemplate = -> require('../templates/order_confirmation_link_modal.jade') arguments...
invoiceLinkTemplate = -> require('../templates/invoice_link_modal.jade') arguments...

module.exports.OrdersView = class OrdersView extends Backbone.View

  initialize: (options) ->
    @setupPreviewLinkModals()
    @setupInvoiceLinkModals()

  setupPreviewLinkModals: ->
    _.each $('.preview-order-link'), (el) ->
      new ModalDialog
        $trigger: $(el)
        template: orderConfirmationLinkTemplate url: $(el).data 'url'

  setupInvoiceLinkModals: ->
    _.each $('.preview-invoice-link'), (el) ->
      return unless (order_id = $(el).data('order-id'))?
      invoices = new Invoices()
      Q(invoices.fetch data: order_id: order_id, sort: '-created_at')
        .then ->
          invoice = invoices.at(0)  # use the latest invoice
          return unless invoice?
          new ModalDialog
            $trigger: $(el)
            template: invoiceLinkTemplate url: "#{invoice.href()}?access_key=#{invoice.get('access_key')}"
        .catch (error) ->
          console.log error
        .done()

module.exports.init = ->
  new OrdersView
    el: $ "body"
    orders: new Orders ORDERS
