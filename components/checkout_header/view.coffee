_ = require 'underscore'
_s = require 'underscore.string'
Backbone = require 'backbone'
sd = require('sharify').data
mediator = require '../../lib/mediator.coffee'

module.exports = class CheckoutHeaderView extends Backbone.View
  #block: '#checkout-header'
  initialize: ->
    #waypoints = $('#checkout-header').waypoint(
    waypoints = @$el.waypoint(
      (direction) ->
        console.log this.element.id + ' hit 250px from top of the block',
        if direction is 'down'
          $('#checkout-header').css('background-color', '#dddddd');
        if direction is 'up'
          $('#checkout-header').css('background-color', '#FD5650');
      offset: -250
      )