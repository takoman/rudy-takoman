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
Backbone.$ = $
sd = require("sharify").data
CurrentUser = require "../../models/current_user.coffee"

module.exports.AuthView = class AuthView extends Backbone.View

  initialize: ->
    @user = CurrentUser.orNull()
    if @user
      $('#auth-message').html "Logged in as #{@user?.get 'email'}"
    else
      $('#auth-message').html "Not logged in"

  events:
    "submit #sign-up": "signUp"
    "submit #log-in": "logIn"

  logIn: (e) ->
    e.preventDefault()

    model = new Backbone.Model
      email: $('form#log-in input[name="email"]').val()
      password: $('form#log-in input[name="password"]').val()

    model.url = -> "/users/login"
    model.save {},
      success: (model, res, opt) ->
        $('#auth-message').html(res.message)
          .removeClass().addClass 'alert alert-success'
      error: (model, xhr, opt) ->
        error = $.parseJSON(xhr.responseText)
        $('#auth-message').html(error.message)
          .removeClass().addClass 'alert alert-danger'

  signUp: (e) ->
    e.preventDefault()

    model = new Backbone.Model
      name: $('form#sign-up input[name="email"]').val()
      email: $('form#sign-up input[name="email"]').val()
      password: $('form#sign-up input[name="password"]').val()

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
