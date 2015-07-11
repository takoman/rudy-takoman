_ = require 'underscore'
{ API_URL, APP_URL } = require('sharify').data

module.exports =
  related: ->
    return @__related__ if @__related__?

    OrderLineItem = require '../../../models/order_line_item.coffee'

    order_line_item = new OrderLineItem(
      if _.isString(@get('order_line_item')) then { _id: @get('order_line_item') } else @get('order_line_item')
    )

    @__related__ =
      order_line_item: order_line_item
