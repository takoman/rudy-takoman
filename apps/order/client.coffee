Backbone = require 'backbone'
Backbone.$ = $
sd = require('sharify').data
CheckoutHeaderView = require '../../components/checkout_header/view.coffee'

module.exports.OrderView = class OrderView extends Backbone.View

  initialize: ->
    @checkoutHeaderView = new CheckoutHeaderView
      el: @$('#checkout-header')

module.exports.init = ->
  new CheckoutHeaderView
    el: $('#checkout-header')