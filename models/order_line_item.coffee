_ = require 'underscore'
Backbone = require 'backbone'
Relations = require './mixins/relations/order_line_item.coffee'
SantaModel = require './mixins/santa_model.coffee'
{ API_URL } = require('sharify').data

module.exports = class OrderLineItem extends Backbone.Model

  _.extend @prototype, Relations
  _.extend @prototype, SantaModel

  defaults: ->
    price: 0
    quantity: 0

  urlRoot: "#{API_URL}/api/v1/order_line_items"

  title: ->
    if @get('type') is 'shipping'
      '運費'
    else if @get('type') is 'commission'
      '代買費'
    else if @get('type') is 'product'
      @related().product.get('title') or '商品'
    else if @get('type') is 'tax'
      '稅金'
    else
      '項目'

  isProduct: -> @get('type') is 'product'

  productImage: (version = 'original') ->
    return unless @isProduct()
    @related().product?.get('images')?[0]?[version]
