Backbone = require 'backbone'
sd = require('sharify').data
ProfileHeaderView = require '../../../components/profile_header/view.coffee'

module.exports.ProfileView = class ProfileView extends Backbone.View

  initialize: ->
    @initializeHeader()

  events:
    'submit #form-contact': 'saveContact'

  initializeHeader: ->
    new ProfileHeaderView el: $('.profile-header')

  saveContact: (e) ->
    e.preventDefault()
    @$('#contact-form-block').addClass('submitted')
    @$('#contact-paper').addClass('submitted')
    @$('#contact-envelop-top').addClass('submitted')

module.exports.init = ->
  new ProfileView
    el: $ 'body'
