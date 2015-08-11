Backbone = require 'backbone'
sd = require('sharify').data
ProfileHeaderView = require '../../../components/profile_header/view.coffee'

module.exports.ProfileView = class ProfileView extends Backbone.View

  initialize: ->
    @initializeHeader()

  initializeHeader: ->
    new ProfileHeaderView el: $('.profile-header')

module.exports.init = ->
  new ProfileView
    el: $ 'body'
