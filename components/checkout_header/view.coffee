_ = require 'underscore'
_s = require 'underscore.string'
Backbone = require 'backbone'
sd = require('sharify').data
mediator = require '../../lib/mediator.coffee'

module.exports = class CheckoutHeaderView extends Backbone.View
  initialize: ->
    waypoints = @$el.waypoint(
      (direction) ->
        if direction is 'down'
          $('#checkout-header').css('background-color', '#dddddd');
        if direction is 'up'
          $('#checkout-header').css('background-color', '#FD5650');
      , offset: -250
    )