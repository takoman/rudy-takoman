Backbone = require 'backbone'
sd = require('sharify').data
ProfileHeaderView = require '../../../components/profile_header/view.coffee'

module.exports.ProfileView = class ProfileView extends Backbone.View

  initialize: ->
    @initializeHeader()

  events:
    'submit #form-contact': 'saveContact'
    'click #re-contact': 'reContact'

  initializeHeader: ->
    new ProfileHeaderView el: $('.profile-header')

  saveContact: (e) ->
    e.preventDefault()
    @$('.contact-effect').addClass('submitted')

  reContact: (e) ->
    e.preventDefault()
    @$('.contact-effect').removeClass('submitted')
    @$('#form-contact input, #form-contact textarea').val('')


module.exports.init = ->
  new ProfileView
    el: $ 'body'
