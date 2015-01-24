Backbone = require 'backbone'
Backbone.$ = $
sd = require('sharify').data
CheckoutHeaderView = require '../../components/checkout_header/view.coffee'

module.exports.init = ->
  new CheckoutHeaderView