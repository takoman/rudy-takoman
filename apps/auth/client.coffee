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
sd = require("sharify").data
CurrentUser = require "../../models/current_user.coffee"

module.exports.AuthView = class AuthView extends Backbone.View

  initialize: ->
    @user = CurrentUser.orNull()

  events:
    "submit #form-signup": "signup"
    "submit #form-login": "login"

  login: (e) ->
    e.preventDefault()

    model = new Backbone.Model
      email: $('#form-login input[name="email"]').val()
      password: $('#form-login input[name="password"]').val()

    model.url = -> "/users/login"
    model.save {},
      success: (model, res, opt) ->
        $('#auth-message').html(res.message)
          .removeClass().addClass 'alert alert-success'
      error: (model, xhr, opt) ->
        error = $.parseJSON(xhr.responseText)
        $('#auth-message').html(error.message)
          .removeClass().addClass 'alert alert-danger'

  signup: (e) ->
    e.preventDefault()

    model = new Backbone.Model
      name: $('#form-signup input[name="email"]').val()
      email: $('#form-signup input[name="email"]').val()
      password: $('#form-signup input[name="password"]').val()

    model.url = -> "/users/signup"
    model.save {},
      success: (model, res, opt) ->
        $('#auth-message').html(res.message)
          .removeClass().addClass 'alert alert-success'
      error: (model, xhr, opt) ->
        error = $.parseJSON(xhr.responseText)
        $('#auth-message').html(error.message)
          .removeClass().addClass 'alert alert-danger'

module.exports.init = ->
  new AuthView el: $ "body"
