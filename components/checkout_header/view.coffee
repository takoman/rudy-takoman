Backbone = require 'backbone'

module.exports = class CheckoutHeaderView extends Backbone.View
  initialize: ->
    @$el.waypoint (direction) =>
      if direction is 'down'
        @$el.css 'background-color', '#dddddd'
      if direction is 'up'
        @$el.css 'background-color', '#fd5650'
    , offset: -> - @element.clientHeight / 2
