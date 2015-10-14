_ = require 'underscore'
Backbone = require "backbone"
ModalAuthView = require '../../../components/modal_auth/view.coffee'

module.exports.HomeView = class HomeView extends Backbone.View
  initialize: ->
    new ModalAuthView $trigger: @$('#login, #signup')

module.exports.init = ->
  new HomeView el: $ "body"
