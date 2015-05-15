_ = require 'underscore'
Backbone = require 'backbone'
Relations = require './mixins/relations/order_line_item.coffee'
{ API_URL } = require('sharify').data

module.exports = class OrderLineItem extends Backbone.Model

  _.extend @prototype, Relations

  defaults: ->
    price: 0
    quantity: 0

  urlRoot: "#{API_URL}/api/v1/order_line_items"
