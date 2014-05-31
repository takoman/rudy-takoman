#
# The client-side code for the commits page.
#
# [Browserify](https://github.com/substack/node-browserify) lets us write this
# code as a common.js module, which means requiring dependecies instead of
# relying on globals. This module exports the Backbone view and an init
# function that gets used in /assets/commits.coffee. Doing this allows us to
# easily unit test these components, and makes the code more modular and
# composable in general.
#

Backbone = require "backbone"
#$ = require 'jquery'
Backbone.$ = $
sd = require("sharify").data
ModalView = require "../../components/modal/view.coffee"
class SingInModal extends ModalView
  template: -> require "./templates/signin_form.jade"

module.exports.AuthView = class AuthView extends Backbone.View

  initialize: ->

  events:
    "click .modal-button": "openModal"

  openModal: (e) ->
    new SingInModal()

module.exports.init = ->
  new AuthView
    el: $ "body"
