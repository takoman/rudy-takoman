_ = require 'underscore'
_s = require 'underscore.string'
Q = require 'q'
Backbone = require "backbone"
Orders = require "../../../collections/orders.coffee"
ModalDialog = require "../../../components/modal_dialog/view.coffee"
{ API_URL, ORDERS } = require('sharify').data
orderConfirmationLinkTemplate = -> require('../templates/order_confirmation_link_modal.jade') arguments...

module.exports.OrdersView = class OrdersView extends Backbone.View

  initialize: (options) ->
    @setupPreviewLinkModals()

  setupPreviewLinkModals: ->
    _.each $('.preview-order-link'), (el) ->
      new ModalDialog
        $trigger: $(el)
        template: orderConfirmationLinkTemplate url: $(el).data 'url'

module.exports.init = ->
  new OrdersView
    el: $ "body"
    orders: new Orders ORDERS
