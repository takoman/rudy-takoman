_ = require 'underscore'
Backbone = require 'backbone'
Relations = require './mixins/relations/invoice_line_item.coffee'
SantaModel = require './mixins/santa_model.coffee'
{ API_URL } = require('sharify').data

module.exports = class InvoiceLineItem extends Backbone.Model

  _.extend @prototype, Relations
  _.extend @prototype, SantaModel

  urlRoot: "#{API_URL}/api/v1/invoice_line_items"

  title: ->
    return unless @get('order_line_item')?
    if @get('order_line_item')['type'] is 'product'
      "商品"
    else if @get('order_line_item')['type'] is 'commission'
      "代買費"
    else if @get('order_line_item')['type'] is 'shipping'
      "運費"
    else
      ""
