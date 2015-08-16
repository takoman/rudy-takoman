Backbone = require 'backbone'

module.exports = class ProfileHeaderView extends Backbone.View

  initialize: ->

    @$('.profile-info').waypoint (direction) =>
      if direction is 'down'
        $('.sticky-navbar').addClass('show')
      if direction is 'up'
        $('.sticky-navbar').removeClass('show')
    , offset: -> $('.sticky-navbar').height() - $('.profile-info').height()
